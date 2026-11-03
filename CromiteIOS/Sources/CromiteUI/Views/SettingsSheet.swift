import SwiftUI
import WebKit
import CromiteCore

public struct SettingsSheet: View {
    @ObservedObject var settings = PrivacySettings.shared
    @StateObject private var uiState = SettingsUIState()
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("Search Engine") {
                    Picker("Default Search", selection: $settings.searchEngine) {
                        ForEach(SearchEngine.allCases, id: \.self) { engine in
                            Text(engine.rawValue).tag(engine)
                        }
                    }
                }

                Section("Shields & Ad Blocking") {
                    Toggle("Built-in Ad Blocking", isOn: $settings.adBlockingEnabled)
                    Toggle("Block Cross-Site Trackers", isOn: $settings.trackerBlockingEnabled)
                    Toggle("Strip Tracking Parameters", isOn: $settings.stripTrackingParams)
                }

                Section("Anti-Fingerprinting Mitigations") {
                    Toggle("Anti-Fingerprinting Shield", isOn: $settings.antiFingerprintingEnabled)
                    Toggle("Canvas Noise Perturbation", isOn: $settings.canvasPoisoningEnabled)
                    Toggle("Audio Frequency Perturbation", isOn: $settings.audioPoisoningEnabled)
                    Toggle("Disable Battery Status API", isOn: $settings.blockBatteryApi)
                    Toggle("Prevent WebRTC IP Leaks", isOn: $settings.blockWebRTCLeaks)
                }

                Section("Security & Web Standards") {
                    Toggle("HTTPS-Only Mode", isOn: $settings.httpsOnlyMode)
                    Toggle("Block Pop-up Windows", isOn: $settings.blockPopups)
                    Toggle("Enable JavaScript", isOn: $settings.javaScriptEnabled)
                }

                Section("Privacy & Data Retention") {
                    Toggle("Always Incognito (Ephemeral Storage)", isOn: $settings.alwaysIncognito)

                    Picker("History Retention", selection: $settings.historyRetentionDays) {
                        Text("Disabled (0 days)").tag(0)
                        Text("7 Days").tag(7)
                        Text("30 Days").tag(30)
                        Text("90 Days").tag(90)
                    }

                    Button(role: .destructive, action: { uiState.showingClearConfirmation = true }) {
                        Label("Clear All Website Data & Cookies", systemImage: "trash")
                    }
                }

                Section("About Cromite for Apple") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Cromite Swift)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Based on")
                        Spacer()
                        Text("Cromite & WebKit Engine")
                            .foregroundColor(.secondary)
                    }
                    Link("Cromite Project Website", destination: URL(string: "https://www.cromite.org")!)
                    Button("Reset All Settings to Default") {
                        settings.resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Clear all cookies, cache, and website data?",
                isPresented: $uiState.showingClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear Everything", role: .destructive) {
                    clearAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func clearAllData() {
        let store = WKWebsiteDataStore.default()
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        let dateFrom = Date(timeIntervalSince1970: 0)
        store.removeData(ofTypes: types, modifiedSince: dateFrom) {
            HistoryManager.shared.clearAllHistory()
        }
    }
}
