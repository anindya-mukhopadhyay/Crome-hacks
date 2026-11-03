import Foundation
import WebKit

@MainActor
public final class AdBlockEngine {
    public static let shared = AdBlockEngine()

    private var compiledRuleList: WKContentRuleList?
    private let ruleListIdentifier = "CromiteAdBlockAndPrivacyRules"

    public init() {}

    /// Built-in high performance JSON rule list based on Cromite & EasyList/EasyPrivacy core protections
    public static func defaultRulesJSON() -> String {
        return """
        [
            {
                "trigger": {
                    "url-filter": ".*",
                    "resource-type": ["script", "image", "media", "raw"],
                    "load-type": ["third-party"],
                    "if-domain": [
                        "*doubleclick.net*",
                        "*googlesyndication.com*",
                        "*google-analytics.com*",
                        "*googletagservices.com*",
                        "*googletagmanager.com*",
                        "*adservice.google.com*",
                        "*pagead2.googlesyndication.com*",
                        "*adsystem.com*",
                        "*adroll.com*",
                        "*criteo.com*",
                        "*criteo.net*",
                        "*taboola.com*",
                        "*outbrain.com*",
                        "*scorecardresearch.com*",
                        "*quantserve.com*",
                        "*rubiconproject.com*",
                        "*pubmatic.com*",
                        "*openx.net*",
                        "*casale-media.com*",
                        "*adnxs.com*",
                        "*adsrvr.org*",
                        "*bidswitch.net*",
                        "*moatads.com*",
                        "*app-measurement.com*",
                        "*hotjar.com*",
                        "*clarity.ms*",
                        "*yandex.ru*",
                        "*mc.yandex.ru*",
                        "*connect.facebook.net*",
                        "*analytics.twitter.com*",
                        "*ads-twitter.com*"
                    ]
                },
                "action": {
                    "type": "block"
                }
            },
            {
                "trigger": {
                    "url-filter": ".*(adserver|adservices|adsystem|doubleclick|googleads|pagead|analytics|telemetry|beacon).*\\\\.js"
                },
                "action": {
                    "type": "block"
                }
            },
            {
                "trigger": {
                    "url-filter": ".*",
                    "resource-type": ["popup"]
                },
                "action": {
                    "type": "block"
                }
            },
            {
                "trigger": {
                    "url-filter": ".*",
                    "resource-type": ["image", "style-sheet"],
                    "if-domain": ["*tracking*", "*telemetry*"]
                },
                "action": {
                    "type": "block"
                }
            },
            {
                "trigger": {
                    "url-filter": ".*",
                    "resource-type": ["raw"],
                    "load-type": ["third-party"],
                    "if-domain": ["*facebook.com*", "*tiktok.com*"]
                },
                "action": {
                    "type": "block-cookies"
                }
            }
        ]
        """
    }

    /// Compiles or retrieves the cached WKContentRuleList
    public func getCompiledRules() async throws -> WKContentRuleList? {
        if let existing = compiledRuleList {
            return existing
        }

        guard let store = WKContentRuleListStore.default() else {
            return nil
        }
        
        // Attempt to look up pre-compiled list
        if let cached = try? await store.contentRuleList(forIdentifier: ruleListIdentifier) {
            self.compiledRuleList = cached
            return cached
        }

        // Compile rules from JSON
        let json = Self.defaultRulesJSON()
        let compiled = try await store.compileContentRuleList(
            forIdentifier: ruleListIdentifier,
            encodedContentRuleList: json
        )
        self.compiledRuleList = compiled
        return compiled
    }

    /// Attaches the Cromite ad/tracker blocking rule list to a WKUserContentController
    public func attach(to controller: WKUserContentController) async {
        do {
            if let rules = try await getCompiledRules() {
                controller.add(rules)
            }
        } catch {
            print("[CromiteAdBlock] Error compiling content rule list: \(error)")
        }
    }
}
