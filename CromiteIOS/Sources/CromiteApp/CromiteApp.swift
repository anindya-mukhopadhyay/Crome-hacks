import SwiftUI
import CromiteCore
import CromiteUI

@main
struct CromiteApp: App {
    init() {
        // Pre-compile adblock rules and initialize settings on app launch
        Task {
            _ = try? await AdBlockEngine.shared.getCompiledRules()
        }
    }

    var body: some Scene {
        WindowGroup {
            BrowserView()
                #if os(macOS)
                .frame(minWidth: 800, minHeight: 600)
                #endif
        }
    }
}

