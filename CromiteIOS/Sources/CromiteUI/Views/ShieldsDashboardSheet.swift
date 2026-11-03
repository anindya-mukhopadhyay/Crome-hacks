import SwiftUI
import WebKit
import CromiteCore

public struct ShieldsDashboardSheet: View {
    @ObservedObject var tab: CromiteTab
    @ObservedObject var settings = PrivacySettings.shared
    @Environment(\.dismiss) private var dismiss

    public init(tab: CromiteTab) {
        self.tab = tab
    }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.green)
                            VStack(alignment: .leading) {
                                Text("Cromite Shields")
                                    .font(.title3.bold())
                                Text(tab.currentURL?.host ?? "Current Site")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Divider()

                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(tab.blockedTrackersCount)")
                                    .font(.title2.bold())
                                    .foregroundColor(.blue)
                                Text("Trackers Blocked")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("\(tab.strippedParamsCount)")
                                    .font(.title2.bold())
                                    .foregroundColor(.orange)
                                Text("Params Stripped")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Image(systemName: tab.isSecureConnection ? "lock.fill" : "lock.open.fill")
                                    .font(.title2.bold())
                                    .foregroundColor(tab.isSecureConnection ? .green : .red)
                                Text(tab.isSecureConnection ? "HTTPS Secure" : "Unencrypted")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Site Protections") {
                    Toggle("Ad & Tracker Blocking", isOn: $settings.adBlockingEnabled)
                    Toggle("Anti-Fingerprinting Shield", isOn: $settings.antiFingerprintingEnabled)
                    Toggle("Strip Tracking Parameters", isOn: $settings.stripTrackingParams)
                    Toggle("Strict HTTPS Upgrade", isOn: $settings.httpsOnlyMode)
                }

                Section("Active Anti-Fingerprinting Mitigations") {
                    Label("Canvas Noise Perturbation", systemImage: "paintbrush.fill")
                    Label("AudioBuffer & Frequency Spoofing", systemImage: "waveform")
                    Label("WebRTC Local IP Cloaking", systemImage: "network")
                    Label("Battery & Hardware Normalization", systemImage: "battery.100")
                }

                Section {
                    Button(role: .destructive, action: clearCurrentSiteData) {
                        Label("Clear Cookies & Storage for this Site", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Privacy Shield")
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
        }
    }

    private func clearCurrentSiteData() {
        guard let host = tab.currentURL?.host else { return }
        let store = tab.webView.configuration.websiteDataStore
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()

        store.fetchDataRecords(ofTypes: dataTypes) { records in
            let matching = records.filter { $0.displayName.contains(host) }
            store.removeData(ofTypes: dataTypes, for: matching) {
                Task { @MainActor in
                    tab.reload()
                    dismiss()
                }
            }
        }
    }
}

