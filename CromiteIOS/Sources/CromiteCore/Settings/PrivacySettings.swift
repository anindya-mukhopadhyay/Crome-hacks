import Foundation
import Combine

public enum SearchEngine: String, CaseIterable, Codable, Sendable {
    case duckDuckGo = "DuckDuckGo"
    case brave = "Brave Search"
    case startpage = "Startpage"
    case googleEnglish = "Google (English Only, No RLZ)"
    case kagi = "Kagi"

    public func searchURL(for query: String) -> URL? {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        switch self {
        case .duckDuckGo:
            return URL(string: "https://duckduckgo.com/?q=\(encoded)&kp=-2&kd=-1") // safe, privacy defaults
        case .brave:
            return URL(string: "https://search.brave.com/search?q=\(encoded)")
        case .startpage:
            return URL(string: "https://www.startpage.com/sp/search?query=\(encoded)")
        case .googleEnglish:
            // Cromite feature: English only, disable tracking querystrings
            return URL(string: "https://www.google.com/search?q=\(encoded)&hl=en&gl=us&pws=0")
        case .kagi:
            return URL(string: "https://kagi.com/search?q=\(encoded)")
        }
    }
}

public final class PrivacySettings: ObservableObject, @unchecked Sendable {
    public static let shared = PrivacySettings()

    private let defaults: UserDefaults

    @Published public var adBlockingEnabled: Bool {
        didSet { defaults.set(adBlockingEnabled, forKey: "adBlockingEnabled") }
    }
    @Published public var trackerBlockingEnabled: Bool {
        didSet { defaults.set(trackerBlockingEnabled, forKey: "trackerBlockingEnabled") }
    }
    @Published public var antiFingerprintingEnabled: Bool {
        didSet { defaults.set(antiFingerprintingEnabled, forKey: "antiFingerprintingEnabled") }
    }
    @Published public var canvasPoisoningEnabled: Bool {
        didSet { defaults.set(canvasPoisoningEnabled, forKey: "canvasPoisoningEnabled") }
    }
    @Published public var audioPoisoningEnabled: Bool {
        didSet { defaults.set(audioPoisoningEnabled, forKey: "audioPoisoningEnabled") }
    }
    @Published public var blockBatteryApi: Bool {
        didSet { defaults.set(blockBatteryApi, forKey: "blockBatteryApi") }
    }
    @Published public var blockWebRTCLeaks: Bool {
        didSet { defaults.set(blockWebRTCLeaks, forKey: "blockWebRTCLeaks") }
    }
    @Published public var stripTrackingParams: Bool {
        didSet { defaults.set(stripTrackingParams, forKey: "stripTrackingParams") }
    }
    @Published public var httpsOnlyMode: Bool {
        didSet { defaults.set(httpsOnlyMode, forKey: "httpsOnlyMode") }
    }
    @Published public var alwaysIncognito: Bool {
        didSet { defaults.set(alwaysIncognito, forKey: "alwaysIncognito") }
    }
    @Published public var clearDataOnExit: Bool {
        didSet { defaults.set(clearDataOnExit, forKey: "clearDataOnExit") }
    }
    @Published public var searchEngine: SearchEngine {
        didSet { defaults.set(searchEngine.rawValue, forKey: "searchEngine") }
    }
    @Published public var customUserAgent: String? {
        didSet { defaults.set(customUserAgent, forKey: "customUserAgent") }
    }
    @Published public var historyRetentionDays: Int {
        didSet { defaults.set(historyRetentionDays, forKey: "historyRetentionDays") }
    }
    @Published public var blockPopups: Bool {
        didSet { defaults.set(blockPopups, forKey: "blockPopups") }
    }
    @Published public var javaScriptEnabled: Bool {
        didSet { defaults.set(javaScriptEnabled, forKey: "javaScriptEnabled") }
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        self.adBlockingEnabled = defaults.object(forKey: "adBlockingEnabled") as? Bool ?? true
        self.trackerBlockingEnabled = defaults.object(forKey: "trackerBlockingEnabled") as? Bool ?? true
        self.antiFingerprintingEnabled = defaults.object(forKey: "antiFingerprintingEnabled") as? Bool ?? true
        self.canvasPoisoningEnabled = defaults.object(forKey: "canvasPoisoningEnabled") as? Bool ?? true
        self.audioPoisoningEnabled = defaults.object(forKey: "audioPoisoningEnabled") as? Bool ?? true
        self.blockBatteryApi = defaults.object(forKey: "blockBatteryApi") as? Bool ?? true
        self.blockWebRTCLeaks = defaults.object(forKey: "blockWebRTCLeaks") as? Bool ?? true
        self.stripTrackingParams = defaults.object(forKey: "stripTrackingParams") as? Bool ?? true
        self.httpsOnlyMode = defaults.object(forKey: "httpsOnlyMode") as? Bool ?? true
        self.alwaysIncognito = defaults.object(forKey: "alwaysIncognito") as? Bool ?? false
        self.clearDataOnExit = defaults.object(forKey: "clearDataOnExit") as? Bool ?? false
        self.historyRetentionDays = defaults.object(forKey: "historyRetentionDays") as? Int ?? 7
        self.blockPopups = defaults.object(forKey: "blockPopups") as? Bool ?? true
        self.javaScriptEnabled = defaults.object(forKey: "javaScriptEnabled") as? Bool ?? true

        if let rawEngine = defaults.string(forKey: "searchEngine"),
           let engine = SearchEngine(rawValue: rawEngine) {
            self.searchEngine = engine
        } else {
            self.searchEngine = .duckDuckGo
        }

        self.customUserAgent = defaults.string(forKey: "customUserAgent")
    }

    public func resetToDefaults() {
        adBlockingEnabled = true
        trackerBlockingEnabled = true
        antiFingerprintingEnabled = true
        canvasPoisoningEnabled = true
        audioPoisoningEnabled = true
        blockBatteryApi = true
        blockWebRTCLeaks = true
        stripTrackingParams = true
        httpsOnlyMode = true
        alwaysIncognito = false
        clearDataOnExit = false
        searchEngine = .duckDuckGo
        customUserAgent = nil
        historyRetentionDays = 7
        blockPopups = true
        javaScriptEnabled = true
    }
}

