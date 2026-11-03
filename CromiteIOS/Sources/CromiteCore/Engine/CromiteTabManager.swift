import Foundation
import Combine

@MainActor
public final class CromiteTabManager: ObservableObject {
    public static let shared = CromiteTabManager()

    @Published public private(set) var tabs: [CromiteTab] = []
    @Published public var activeTabId: UUID?

    public var activeTab: CromiteTab? {
        guard let id = activeTabId else { return tabs.first }
        return tabs.first { $0.id == id } ?? tabs.first
    }

    public init() {
        // Open default startup tab
        let startupTab = createNewTab(
            url: URL(string: "https://duckduckgo.com")!,
            isPrivate: PrivacySettings.shared.alwaysIncognito
        )
        self.activeTabId = startupTab.id
    }

    @discardableResult
    public func createNewTab(url: URL? = nil, isPrivate: Bool = false) -> CromiteTab {
        let initialURL = url ?? PrivacySettings.shared.searchEngine.searchURL(for: "") ?? URL(string: "https://duckduckgo.com")
        let tab = CromiteTab(initialURL: initialURL, isPrivate: isPrivate)
        tabs.append(tab)
        activeTabId = tab.id
        return tab
    }

    public func closeTab(id: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        tabs.remove(at: index)

        if activeTabId == id {
            if !tabs.isEmpty {
                let newIndex = min(index, tabs.count - 1)
                activeTabId = tabs[newIndex].id
            } else {
                // If all tabs closed, create a fresh tab
                let fresh = createNewTab()
                activeTabId = fresh.id
            }
        }
    }

    public func closeAllTabs() {
        tabs.removeAll()
        let fresh = createNewTab()
        activeTabId = fresh.id
    }

    public func selectTab(id: UUID) {
        if tabs.contains(where: { $0.id == id }) {
            self.activeTabId = id
        }
    }
}

