import Foundation

public struct BookmarkItem: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public var title: String
    public var url: URL
    public var dateAdded: Date
    public var isFolder: Bool
    public var parentId: UUID?

    public init(
        id: UUID = UUID(),
        title: String,
        url: URL,
        dateAdded: Date = Date(),
        isFolder: Bool = false,
        parentId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.dateAdded = dateAdded
        self.isFolder = isFolder
        self.parentId = parentId
    }
}

public final class BookmarkManager: ObservableObject, @unchecked Sendable {
    public static let shared = BookmarkManager()

    @Published public private(set) var bookmarks: [BookmarkItem] = []
    private let saveURL: URL

    public init(fileManager: FileManager = .default) {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.saveURL = docs.appendingPathComponent("cromite_bookmarks.json")
        loadBookmarks()
        if bookmarks.isEmpty {
            createDefaultBookmarks()
        }
    }

    private func createDefaultBookmarks() {
        let defaults: [BookmarkItem] = [
            BookmarkItem(title: "DuckDuckGo", url: URL(string: "https://duckduckgo.com")!),
            BookmarkItem(title: "Cromite Project", url: URL(string: "https://www.cromite.org")!),
            BookmarkItem(title: "Wikipedia", url: URL(string: "https://wikipedia.org")!),
            BookmarkItem(title: "EFF (Electronic Frontier Foundation)", url: URL(string: "https://www.eff.org")!)
        ]
        self.bookmarks = defaults
        saveBookmarks()
    }

    public func addBookmark(title: String, url: URL, parentId: UUID? = nil) {
        let item = BookmarkItem(title: title.isEmpty ? url.host ?? "Bookmark" : title, url: url, parentId: parentId)
        bookmarks.append(item)
        saveBookmarks()
    }

    public func removeBookmark(id: UUID) {
        bookmarks.removeAll { $0.id == id }
        saveBookmarks()
    }

    public func isBookmarked(url: URL) -> Bool {
        return bookmarks.contains { $0.url == url }
    }

    private func saveBookmarks() {
        do {
            let data = try JSONEncoder().encode(bookmarks)
            try data.write(to: saveURL, options: .atomic)
        } catch {
            print("[BookmarkManager] Failed to save: \(error)")
        }
    }

    private func loadBookmarks() {
        guard let data = try? Data(contentsOf: saveURL),
              let decoded = try? JSONDecoder().decode([BookmarkItem].self, from: data) else {
            return
        }
        self.bookmarks = decoded
    }
}

