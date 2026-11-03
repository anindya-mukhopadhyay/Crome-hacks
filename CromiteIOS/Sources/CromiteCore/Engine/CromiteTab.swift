import Foundation
import WebKit
import Combine

@MainActor
public final class CromiteTab: NSObject, ObservableObject, Identifiable {
    public let id: UUID
    public let isPrivate: Bool

    @Published public var title: String = "New Tab"
    @Published public var currentURL: URL?
    @Published public var canGoBack: Bool = false
    @Published public var canGoForward: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var estimatedProgress: Double = 0.0
    @Published public var isSecureConnection: Bool = false
    @Published public var blockedTrackersCount: Int = 0
    @Published public var strippedParamsCount: Int = 0

    public private(set) var webView: WKWebView!

    private var cancellables = Set<AnyCancellable>()
    private var progressObservation: NSKeyValueObservation?
    private var titleObservation: NSKeyValueObservation?
    private var urlObservation: NSKeyValueObservation?
    private var backObservation: NSKeyValueObservation?
    private var forwardObservation: NSKeyValueObservation?

    public init(id: UUID = UUID(), initialURL: URL? = nil, isPrivate: Bool = false) {
        self.id = id
        self.isPrivate = isPrivate
        self.currentURL = initialURL
        super.init()

        setupWebView()
        if let url = initialURL {
            load(url: url)
        }
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()

        // 1. Storage Partitioning / Ephemeral Incognito Mode
        if isPrivate || PrivacySettings.shared.alwaysIncognito {
            config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        } else {
            config.websiteDataStore = WKWebsiteDataStore.default()
        }

        // 2. JavaScript & Popup settings
        config.defaultWebpagePreferences.allowsContentJavaScript = PrivacySettings.shared.javaScriptEnabled

        let userContentController = WKUserContentController()

        // 3. Attach Anti-Fingerprinting UserScript
        if PrivacySettings.shared.antiFingerprintingEnabled {
            let script = AntiFingerprinting.makeUserScript(
                canvasPoisoning: PrivacySettings.shared.canvasPoisoningEnabled,
                audioPoisoning: PrivacySettings.shared.audioPoisoningEnabled,
                blockBattery: PrivacySettings.shared.blockBatteryApi,
                blockWebRTC: PrivacySettings.shared.blockWebRTCLeaks
            )
            userContentController.addUserScript(script)
        }

        config.userContentController = userContentController

        // 4. Initialize WKWebView
        #if os(iOS)
        self.webView = WKWebView(frame: .zero, configuration: config)
        #else
        self.webView = WKWebView(frame: .zero, configuration: config)
        #endif

        self.webView.navigationDelegate = self

        // 5. Custom User-Agent if configured
        if let customUA = PrivacySettings.shared.customUserAgent, !customUA.isEmpty {
            self.webView.customUserAgent = customUA
        }

        // 6. Asynchronously attach AdBlock Content Rule List
        Task {
            if PrivacySettings.shared.adBlockingEnabled {
                await AdBlockEngine.shared.attach(to: userContentController)
            }
        }

        setupKVO()
    }

    private func setupKVO() {
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] wv, _ in
            Task { @MainActor [weak self] in
                self?.estimatedProgress = wv.estimatedProgress
            }
        }

        titleObservation = webView.observe(\.title, options: [.new]) { [weak self] wv, _ in
            Task { @MainActor [weak self] in
                if let title = wv.title, !title.isEmpty {
                    self?.title = title
                }
            }
        }

        urlObservation = webView.observe(\.url, options: [.new]) { [weak self] wv, _ in
            Task { @MainActor [weak self] in
                self?.currentURL = wv.url
                self?.isSecureConnection = wv.url?.scheme?.lowercased() == "https"
            }
        }

        backObservation = webView.observe(\.canGoBack, options: [.new]) { [weak self] wv, _ in
            Task { @MainActor [weak self] in
                self?.canGoBack = wv.canGoBack
            }
        }

        forwardObservation = webView.observe(\.canGoForward, options: [.new]) { [weak self] wv, _ in
            Task { @MainActor [weak self] in
                self?.canGoForward = wv.canGoForward
            }
        }
    }

    public func load(url: URL) {
        var targetURL = url

        // Strip Tracking Parameters
        if PrivacySettings.shared.stripTrackingParams {
            let (cleaned, stripped) = TrackingParamStripper.clean(url: targetURL)
            if stripped > 0 {
                targetURL = cleaned
                self.strippedParamsCount += stripped
            }
        }

        // Upgrade to HTTPS
        if PrivacySettings.shared.httpsOnlyMode {
            targetURL = PrivacyFirewall.upgradeToHTTPS(url: targetURL)
        }

        let request = URLRequest(url: targetURL)
        webView.load(request)
    }

    public func reload() {
        webView.reload()
    }

    public func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    public func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }

    public func stopLoading() {
        webView.stopLoading()
    }

    deinit {
        progressObservation?.invalidate()
        titleObservation?.invalidate()
        urlObservation?.invalidate()
        backObservation?.invalidate()
        forwardObservation?.invalidate()
    }
}

extension CromiteTab: WKNavigationDelegate {
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // 1. Check Privacy Firewall for blocked telemetry domains
        if let host = url.host, PrivacyFirewall.isHostBlocked(host) {
            self.blockedTrackersCount += 1
            decisionHandler(.cancel)
            return
        }

        // 2. Strip tracking parameters on link clicks
        if navigationAction.navigationType == .linkActivated, PrivacySettings.shared.stripTrackingParams {
            let (cleaned, stripped) = TrackingParamStripper.clean(url: url)
            if stripped > 0 {
                self.strippedParamsCount += stripped
                decisionHandler(.cancel)
                self.load(url: cleaned)
                return
            }
        }

        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.isLoading = true
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.isLoading = false
        if let url = webView.url {
            self.currentURL = url
            let pageTitle = webView.title ?? url.host ?? "Website"
            self.title = pageTitle
            HistoryManager.shared.addEntry(title: pageTitle, url: url, isPrivate: self.isPrivate)
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.isLoading = false
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.isLoading = false
    }
}

