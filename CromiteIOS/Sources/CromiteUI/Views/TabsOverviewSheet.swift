import SwiftUI
import CromiteCore

public struct TabsOverviewSheet: View {
    @ObservedObject var tabManager = CromiteTabManager.shared
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 220), spacing: 16)
    ]

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(tabManager.tabs) { tab in
                        TabCardView(
                            tab: tab,
                            isSelected: tabManager.activeTabId == tab.id,
                            onSelect: {
                                tabManager.selectTab(id: tab.id)
                                dismiss()
                            },
                            onClose: {
                                tabManager.closeTab(id: tab.id)
                            }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Tabs (\(tabManager.tabs.count))")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .destructive, action: { tabManager.closeAllTabs() }) {
                        Text("Close All")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #if os(iOS)
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button(action: {
                            tabManager.createNewTab(isPrivate: true)
                            dismiss()
                        }) {
                            Label("New Private", systemImage: "eye.slash.fill")
                        }

                        Spacer()

                        Button(action: {
                            tabManager.createNewTab(isPrivate: false)
                            dismiss()
                        }) {
                            Label("New Tab", systemImage: "plus")
                        }
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    HStack {
                        Button(action: {
                            tabManager.createNewTab(isPrivate: true)
                            dismiss()
                        }) {
                            Label("New Private", systemImage: "eye.slash.fill")
                        }
                        Button(action: {
                            tabManager.createNewTab(isPrivate: false)
                            dismiss()
                        }) {
                            Label("New Tab", systemImage: "plus")
                        }
                    }
                }
                #endif
            }
        }
    }
}

struct TabCardView: View {
    @ObservedObject var tab: CromiteTab
    let isSelected: Bool
    let onSelect: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if tab.isPrivate {
                    Image(systemName: "eye.slash.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.purple)
                }
                Text(tab.title)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            Text(tab.currentURL?.host ?? "Empty Tab")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(1)

            Spacer()

            HStack {
                if tab.blockedTrackersCount > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 9))
                        Text("\(tab.blockedTrackersCount)")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.green)
                }
                Spacer()
            }
        }
        .padding(12)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 14)
                #if os(iOS)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                #else
                .fill(Color(nsColor: .controlBackgroundColor))
                #endif
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? Color.blue : Color.secondary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}
