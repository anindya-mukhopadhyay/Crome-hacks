import SwiftUI
import CromiteCore

public struct BookmarksSheet: View {
    @ObservedObject var bookmarkManager = BookmarkManager.shared
    @ObservedObject var tabManager = CromiteTabManager.shared
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                if let currentTab = tabManager.activeTab, let url = currentTab.currentURL {
                    Section {
                        Button(action: {
                            bookmarkManager.addBookmark(title: currentTab.title, url: url)
                        }) {
                            Label(
                                bookmarkManager.isBookmarked(url: url) ? "Bookmark Added" : "Bookmark Current Page",
                                systemImage: bookmarkManager.isBookmarked(url: url) ? "star.fill" : "star"
                            )
                            .foregroundColor(bookmarkManager.isBookmarked(url: url) ? .yellow : .primary)
                        }
                        .disabled(bookmarkManager.isBookmarked(url: url))
                    }
                }

                Section("Saved Bookmarks") {
                    if bookmarkManager.bookmarks.isEmpty {
                        Text("No bookmarks saved yet.")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(bookmarkManager.bookmarks) { bookmark in
                            Button(action: {
                                tabManager.activeTab?.load(url: bookmark.url)
                                dismiss()
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(bookmark.title)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.primary)
                                    Text(bookmark.url.absoluteString)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            #if os(iOS)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive, action: {
                                    bookmarkManager.removeBookmark(id: bookmark.id)
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            #endif
                        }
                    }
                }
            }
            .navigationTitle("Bookmarks")
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
}

