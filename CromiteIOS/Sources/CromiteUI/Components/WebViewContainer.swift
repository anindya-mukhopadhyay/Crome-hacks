import SwiftUI
import WebKit
import CromiteCore

#if os(iOS)
public struct WebViewContainer: UIViewRepresentable {
    public let tab: CromiteTab

    public init(tab: CromiteTab) {
        self.tab = tab
    }

    public func makeUIView(context: Context) -> WKWebView {
        return tab.webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
        // Updated via KVO and CromiteTab
    }
}
#else
public struct WebViewContainer: NSViewRepresentable {
    public let tab: CromiteTab

    public init(tab: CromiteTab) {
        self.tab = tab
    }

    public func makeNSView(context: Context) -> WKWebView {
        return tab.webView
    }

    public func updateNSView(_ nsView: WKWebView, context: Context) {
        // Updated via KVO and CromiteTab
    }
}
#endif

