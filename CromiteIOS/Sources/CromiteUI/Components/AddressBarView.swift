import SwiftUI
import CromiteCore

public struct AddressBarView: View {
    @ObservedObject var tab: CromiteTab
    @Binding var isShowingShields: Bool
    @StateObject private var barState = AddressBarState()
    @FocusState private var isFocused: Bool

    public init(tab: CromiteTab, isShowingShields: Binding<Bool>) {
        self.tab = tab
        self._isShowingShields = isShowingShields
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                // Privacy Shield Button
                Button(action: { isShowingShields.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(tab.blockedTrackersCount > 0 || tab.strippedParamsCount > 0 ? .green : .blue)
                            .font(.system(size: 16, weight: .bold))
                        
                        if tab.blockedTrackersCount + tab.strippedParamsCount > 0 {
                            Text("\(tab.blockedTrackersCount + tab.strippedParamsCount)")
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                }
                .buttonStyle(.plain)

                // Lock icon
                if tab.isSecureConnection {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                } else if let url = tab.currentURL, url.scheme == "http" {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                }

                // URL / Search input
                TextField("Search or enter website address", text: $barState.inputText)
                    .focused($isFocused)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                    .autocorrectionDisabled()
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.webSearch)
                    #endif
                    .onSubmit {
                        submitURL()
                    }
                    .onAppear {
                        updateInputText()
                    }
                    .onChange(of: tab.currentURL) { _, _ in
                        if !isFocused {
                            updateInputText()
                        }
                    }

                // Action button: Stop or Reload
                if tab.isLoading {
                    Button(action: { tab.stopLoading() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: { tab.reload() }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    #if os(iOS)
                    .fill(Color(uiColor: .secondarySystemBackground))
                    #else
                    .fill(Color(nsColor: .windowBackgroundColor))
                    #endif
            )

            // Progress bar
            if tab.isLoading && tab.estimatedProgress > 0 && tab.estimatedProgress < 1.0 {
                ProgressView(value: tab.estimatedProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 2)
                    .padding(.top, 2)
            }
        }
    }

    private func updateInputText() {
        if let host = tab.currentURL?.host {
            barState.inputText = host
        } else if let urlString = tab.currentURL?.absoluteString {
            barState.inputText = urlString
        } else {
            barState.inputText = ""
        }
    }

    private func submitURL() {
        let trimmed = barState.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Check if user entered a full URL
        if let url = URL(string: trimmed), ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
            tab.load(url: url)
            return
        }

        // Check if looks like a domain name: e.g. "github.com", "cromite.org"
        if trimmed.contains(".") && !trimmed.contains(" ") {
            if let url = URL(string: "https://" + trimmed) {
                tab.load(url: url)
                return
            }
        }

        // Otherwise, send to configured search engine
        if let searchURL = PrivacySettings.shared.searchEngine.searchURL(for: trimmed) {
            tab.load(url: searchURL)
        }
    }
}
