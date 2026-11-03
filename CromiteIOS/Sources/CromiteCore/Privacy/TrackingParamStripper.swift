import Foundation

public struct TrackingParamStripper: Sendable {
    public static let knownTrackingParameters: Set<String> = [
        "utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content", "utm_id",
        "gclid", "gclsrc", "dclid",
        "fbclid",
        "msclkid",
        "twclid",
        "igshid",
        "mc_eid", "mc_cid",
        "_hsenc", "_hsmi",
        "_openstat",
        "yclid",
        "wickedid",
        "rb_clickid",
        "s_kwcid",
        "vero_id", "vero_conv",
        "ref_", "fref",
        "sc_src", "sc_lid",
        "trk_contact", "trk_msg", "trk_module", "trk_sid"
    ]

    /// Strips known tracking query parameters from the given URL.
    /// Returns the cleaned URL and whether any parameters were removed.
    public static func clean(url: URL) -> (cleanedURL: URL, strippedCount: Int) {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems, !queryItems.isEmpty else {
            return (url, 0)
        }

        let originalCount = queryItems.count
        let filteredItems = queryItems.filter { item in
            let lower = item.name.lowercased()
            if knownTrackingParameters.contains(lower) {
                return false
            }
            // Also filter any utm_* or prefix
            if lower.hasPrefix("utm_") {
                return false
            }
            return true
        }

        let strippedCount = originalCount - filteredItems.count
        if strippedCount > 0 {
            components.queryItems = filteredItems.isEmpty ? nil : filteredItems
            if let result = components.url {
                return (result, strippedCount)
            }
        }

        return (url, 0)
    }
}

