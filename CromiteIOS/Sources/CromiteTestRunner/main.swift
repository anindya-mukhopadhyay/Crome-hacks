import Foundation
import CromiteCore

@main
struct CromiteTestRunner {
    static func main() {
        print("========================================")
        print("  Running Cromite Core Validation Suite ")
        print("========================================")

        testTrackingParamStripper()
        testPrivacyFirewall()
        testHTTPSUpgrade()
        testAntiFingerprintingScript()
        testSearchEngines()

        print("\n✅ All Cromite Core tests passed successfully!")
    }

    static func testTrackingParamStripper() {
        print("-> Testing URL Tracking Parameter Stripping...")
        let testURL = URL(string: "https://example.com/page?utm_source=twitter&utm_medium=social&gclid=12345&article=hello")!
        let (cleaned, stripped) = TrackingParamStripper.clean(url: testURL)

        assert(stripped == 3, "Expected 3 stripped params, got \(stripped)")
        assert(cleaned.absoluteString.contains("article=hello"), "Cleaned URL missing article param")
        assert(!cleaned.absoluteString.contains("utm_source"), "Cleaned URL still contains utm_source")
        assert(!cleaned.absoluteString.contains("utm_medium"), "Cleaned URL still contains utm_medium")
        assert(!cleaned.absoluteString.contains("gclid"), "Cleaned URL still contains gclid")
        print("   [PASS] Stripped \(stripped) tracking parameters correctly.")
    }

    static func testPrivacyFirewall() {
        print("-> Testing Privacy Firewall Domain Blocking...")
        assert(PrivacyFirewall.isHostBlocked("google-analytics.com"), "google-analytics should be blocked")
        assert(PrivacyFirewall.isHostBlocked("sub.google-analytics.com"), "sub.google-analytics should be blocked")
        assert(PrivacyFirewall.isHostBlocked("stats.g.doubleclick.net"), "doubleclick should be blocked")
        assert(PrivacyFirewall.isHostBlocked("connect.facebook.net"), "connect.facebook should be blocked")
        assert(!PrivacyFirewall.isHostBlocked("apple.com"), "apple.com should not be blocked")
        assert(!PrivacyFirewall.isHostBlocked("cromite.org"), "cromite.org should not be blocked")
        print("   [PASS] Firewall accurately blocked tracking telemetry.")
    }

    static func testHTTPSUpgrade() {
        print("-> Testing HTTPS Upgrade...")
        let insecure = URL(string: "http://example.com/privacy-test")!
        let upgraded = PrivacyFirewall.upgradeToHTTPS(url: insecure)
        assert(upgraded.scheme == "https", "Scheme should be upgraded to https")
        assert(upgraded.host == "example.com", "Host should match")
        assert(upgraded.path == "/privacy-test", "Path should match")
        print("   [PASS] Upgraded insecure HTTP to HTTPS.")
    }

    static func testAntiFingerprintingScript() {
        print("-> Testing Anti-Fingerprinting Script Generation...")
        let script = AntiFingerprinting.scriptContent(
            canvasPoisoning: true,
            audioPoisoning: true,
            blockBattery: true,
            blockWebRTC: true
        )
        assert(script.contains("globalPrivacyControl"), "Missing GPC definition")
        assert(script.contains("doNotTrack"), "Missing DNT definition")
        assert(script.contains("applySubtleNoise"), "Missing canvas noise function")
        assert(script.contains("getBattery"), "Missing battery protection")
        assert(script.contains("RTCPeerConnection"), "Missing WebRTC protection")
        print("   [PASS] Generated comprehensive client protection scripts.")
    }

    static func testSearchEngines() {
        print("-> Testing Cromite Search Engines...")
        let query = "privacy browser"
        let ddg = SearchEngine.duckDuckGo.searchURL(for: query)
        assert(ddg != nil && ddg!.absoluteString.contains("duckduckgo.com"), "DDG url invalid")

        let googleEn = SearchEngine.googleEnglish.searchURL(for: query)
        assert(googleEn != nil && googleEn!.absoluteString.contains("hl=en"), "Google English url invalid")
        print("   [PASS] Search engines configured with privacy querystrings.")
    }
}
