import Foundation

public struct HistoryEntry: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public let title: String
    public let url: URL
    public let timestamp: Date

    public init(id: UUID = UUID(), title: String, url: URL, timestamp: Date = Date()) {
        self.id = id
        self.title = title.isEmpty ? (url.host ?? url.absoluteString) : title
        self.url = url
        self.timestamp = timestamp
    }
}

public final class HistoryManager: ObservableObject, @unchecked Sendable {
    public static let shared = HistoryManager()

    @Published public private(set) var entries: [HistoryEntry] = []
    private let saveURL: URL

    public init(fileManager: FileManager = .default) {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.saveURL = docs.appendingPathComponent("cromite_history.json")
        loadHistory()
        pruneExpiredEntries()
    }

    public func addEntry(title: String, url: URL, isPrivate: Bool) {
        // Cromite rule: Private / Incognito browsing never writes to history
        guard !isPrivate else { return }

        // Don't record internal or empty pages
        guard let scheme = url.scheme, ["http", "https"].contains(scheme.lowercased()) else {
            return
        }

        let entry = HistoryEntry(title: title, url: url)
        // Insert at beginning
        entries.insert(entry, at: 0)

        // Limit size
        if entries.count > 5000 {
            entries.removeLast(entries.count - 5000)
        }

        saveHistory()
    }

    public func clearAllHistory() {
        entries.removeAll()
        saveHistory()
    }

    public func removeEntry(id: UUID) {
        entries.removeAll { $0.id == id }
        saveHistory()
    }

    public func pruneExpiredEntries(retentionDays: Int = 7) {
        guard retentionDays > 0 else {
            clearAllHistory()
            return
        }
        let cutoff = Calendar.current.date(byAdding: .day, value: -retentionDays, to: Date()) ?? Date()
        entries.removeAll { $0.timestamp < cutoff }
        saveHistory()
    }

    private func saveHistory() {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: saveURL, options: .atomic)
        } catch {
            print("[HistoryManager] Failed to save history: \(error)")
        }
    }

    private func loadHistory() {
        guard let data = try? Data(contentsOf: saveURL),
              let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) else {
            return
        }
        self.entries = decoded
    }
}

