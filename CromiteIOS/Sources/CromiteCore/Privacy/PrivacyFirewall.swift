import Foundation

public struct PrivacyFirewall: Sendable {
    public static let blockedTelemetryDomains: Set<String> = [
        "google-analytics.com",
        "googletagmanager.com",
        "googletagservices.com",
        "doubleclick.net",
        "adservice.google.com",
        "pagead2.googlesyndication.com",
        "analytics.google.com",
        "stats.g.doubleclick.net",
        "facebook.net",
        "connect.facebook.net",
        "graph.facebook.com",
        "telemetry.mozilla.org",
        "incoming.telemetry.mozilla.org",
        "app-measurement.com",
        "crashlytics.com",
        "hotjar.com",
        "criteo.com",
        "criteo.net",
        "taboola.com",
        "outbrain.com",
        "scorecardresearch.com",
        "quantserve.com",
        "yandex.ru/metrika",
        "mc.yandex.ru"
    ]

    /// Checks if a given host matches a blocked telemetry/tracker domain
    public static func isHostBlocked(_ host: String) -> Bool {
        let lower = host.lowercased()
        for domain in blockedTelemetryDomains {
            if lower == domain || lower.hasSuffix("." + domain) {
                return true
            }
        }
        return false
    }

    /// Automatically upgrades http:// to https:// if HTTPS-Only mode is active
    public static func upgradeToHTTPS(url: URL) -> URL {
        guard url.scheme?.lowercased() == "http" else {
            return url
        }
        var comp = URLComponents(url: url, resolvingAgainstBaseURL: true)
        comp?.scheme = "https"
        return comp?.url ?? url
    }
}

