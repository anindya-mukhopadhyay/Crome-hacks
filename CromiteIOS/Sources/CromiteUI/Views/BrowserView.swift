import SwiftUI
import CromiteCore

public struct BrowserView: View {
    @ObservedObject var tabManager = CromiteTabManager.shared
    @StateObject private var uiState = BrowserUIState()

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            if let activeTab = tabManager.activeTab {
                // Top Omnibar / Address bar
                AddressBarView(tab: activeTab, isShowingShields: $uiState.isShowingShields)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                // Web View Content
                ZStack {
                    WebViewContainer(tab: activeTab)
                        .id(activeTab.id)

                    if activeTab.isPrivate {
                        VStack {
                            HStack {
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: "eye.slash.fill")
                                    Text("Incognito")
                                }
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.purple.opacity(0.85))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                                .padding(8)
                            }
                            Spacer()
                        }
                    }
                }

                // Bottom Toolbar
                HStack(spacing: 0) {
                    // Back Button
                    Button(action: { activeTab.goBack() }) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .disabled(!activeTab.canGoBack)
                    .frame(maxWidth: .infinity)

                    // Forward Button
                    Button(action: { activeTab.goForward() }) {
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .disabled(!activeTab.canGoForward)
                    .frame(maxWidth: .infinity)

                    // Bookmarks Button
                    Button(action: { uiState.isShowingBookmarks = true }) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)

                    // Tabs Switcher Button
                    Button(action: { uiState.isShowingTabs = true }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.primary, lineWidth: 1.5)
                                .frame(width: 22, height: 22)
                            Text("\(tabManager.tabs.count)")
                                .font(.system(size: 11, weight: .bold))
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // Menu / Settings Button
                    Menu {
                        Button(action: { tabManager.createNewTab(isPrivate: false) }) {
                            Label("New Tab", systemImage: "plus")
                        }
                        Button(action: { tabManager.createNewTab(isPrivate: true) }) {
                            Label("New Incognito Tab", systemImage: "eye.slash")
                        }
                        Divider()
                        Button(action: { uiState.isShowingHistory = true }) {
                            Label("History", systemImage: "clock")
                        }
                        Button(action: { uiState.isShowingSettings = true }) {
                            Label("Settings", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .medium))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 10)
                #if os(iOS)
                .background(Color(uiColor: .systemBarBackground))
                #else
                .background(Color(nsColor: .windowBackgroundColor))
                #endif
                .sheet(isPresented: $uiState.isShowingShields) {
                    ShieldsDashboardSheet(tab: activeTab)
                }
            } else {
                Text("No active tab")
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $uiState.isShowingTabs) {
            TabsOverviewSheet()
        }
        .sheet(isPresented: $uiState.isShowingBookmarks) {
            BookmarksSheet()
        }
        .sheet(isPresented: $uiState.isShowingHistory) {
            HistorySheet()
        }
        .sheet(isPresented: $uiState.isShowingSettings) {
            SettingsSheet()
        }
    }
}

#if os(iOS)
extension UIColor {
    static var systemBarBackground: UIColor {
        return .secondarySystemBackground
    }
}
#endif
