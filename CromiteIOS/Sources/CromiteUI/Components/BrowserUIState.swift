import Foundation
import Combine

public final class BrowserUIState: ObservableObject, @unchecked Sendable {
    @Published public var isShowingShields: Bool = false
    @Published public var isShowingTabs: Bool = false
    @Published public var isShowingBookmarks: Bool = false
    @Published public var isShowingHistory: Bool = false
    @Published public var isShowingSettings: Bool = false

    public init() {}
}

public final class AddressBarState: ObservableObject, @unchecked Sendable {
    @Published public var inputText: String = ""

    public init(initialText: String = "") {
        self.inputText = initialText
    }
}

public final class SearchState: ObservableObject, @unchecked Sendable {
    @Published public var searchText: String = ""

    public init(searchText: String = "") {
        self.searchText = searchText
    }
}

public final class SettingsUIState: ObservableObject, @unchecked Sendable {
    @Published public var showingClearConfirmation: Bool = false

    public init() {}
}

