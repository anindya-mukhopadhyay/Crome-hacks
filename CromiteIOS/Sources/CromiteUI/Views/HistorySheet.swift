import SwiftUI
import CromiteCore

public struct HistorySheet: View {
    @ObservedObject var historyManager = HistoryManager.shared
    @ObservedObject var tabManager = CromiteTabManager.shared
    @StateObject private var searchState = SearchState()
    @Environment(\.dismiss) private var dismiss

    public init() {}

    private var filteredEntries: [HistoryEntry] {
        if searchState.searchText.isEmpty {
            return historyManager.entries
        } else {
            return historyManager.entries.filter {
                $0.title.localizedCaseInsensitiveContains(searchState.searchText) ||
                $0.url.absoluteString.localizedCaseInsensitiveContains(searchState.searchText)
            }
        }
    }

    public var body: some View {
        NavigationStack {
            List {
                if filteredEntries.isEmpty {
                    Text(searchState.searchText.isEmpty ? "No browsing history." : "No matching entries found.")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(filteredEntries) { entry in
                        Button(action: {
                            tabManager.activeTab?.load(url: entry.url)
                            dismiss()
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.title)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                HStack {
                                    Text(entry.url.host ?? entry.url.absoluteString)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    Spacer()
                                    Text(entry.timestamp, style: .time)
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        #if os(iOS)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive, action: {
                                historyManager.removeEntry(id: entry.id)
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        #endif
                    }
                }
            }
            .searchable(text: $searchState.searchText, prompt: "Search History")
            .navigationTitle("History")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !historyManager.entries.isEmpty {
                        Button(role: .destructive, action: { historyManager.clearAllHistory() }) {
                            Text("Clear")
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
