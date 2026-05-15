import SwiftUI

/// Scrollable list of all mood entries, grouped by day, with search and swipe-to-delete.
struct JournalView: View {
    @Bindable var vm: JournalViewModel
    var onEdit: ((MoodEntry) -> Void)?
    var onLogMood: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var searchFocused: Bool

    private var entryIDs: [UUID] {
        vm.filteredEntries.map(\.id)
    }

    private var isSearchActive: Bool { !vm.searchText.isEmpty }
    private var showsEmptyJournal: Bool { vm.totalEntryCount == 0 }
    private var showsNoSearchResults: Bool {
        !showsEmptyJournal && vm.filteredEntries.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if showsEmptyJournal {
                    emptyStateScroll
                } else {
                    entryListScroll
                }
            }
            .reflectBackground(moodScore: journalAmbientMood, subdued: showsEmptyJournal)
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var journalAmbientMood: Int {
        vm.filteredEntries.first?.moodScore ?? 3
    }

    // MARK: - List

    private var entryListScroll: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if vm.isFirstStoryPage {
                    firstStoryBanner
                }

                searchBarCard

                if showsNoSearchResults {
                    noResultsCard
                } else {
                    ForEach(vm.groupedByDay, id: \.date) { group in
                        daySectionCard(group: group)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .animation(ReflectMotion.list(reduceMotion: reduceMotion), value: entryIDs)
    }

    private var searchBarCard: some View {
        GlassCard(padding: 12, animate: false) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.rf.body)
                    .foregroundStyle(Color.rfTextMuted)
                    .accessibilityHidden(true)

                TextField("Search tags or notes…", text: $vm.searchText)
                    .font(.rf.body)
                    .foregroundStyle(Color.rfTextPrimary)
                    .focused($searchFocused)
                    .submitLabel(.search)
                    .accessibilityLabel("Search journal")

                if isSearchActive {
                    Button {
                        vm.searchText = ""
                        searchFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.rfTextMuted)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                }
            }
        }
    }

    private func daySectionCard(group: (date: Date, entries: [MoodEntry])) -> some View {
        let sectionMood = group.entries.first?.moodScore ?? 3

        return GlassCard(style: .elevated, padding: 16, animate: false, moodTint: sectionMood) {
            VStack(alignment: .leading, spacing: 14) {
                Text(group.date, format: .dateTime.weekday(.wide).month().day())
                    .font(.rf.headline)
                    .foregroundStyle(Color.rfTextPrimary)
                    .accessibilityAddTraits(.isHeader)

                VStack(spacing: 0) {
                    ForEach(Array(group.entries.enumerated()), id: \.element.id) { index, entry in
                        HStack(alignment: .top, spacing: 14) {
                            JournalTimelineColumn(
                                isFirst: index == 0,
                                isLast: index == group.entries.count - 1,
                                moodScore: entry.moodScore
                            )

                            JournalEntryRow(entry: entry)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 10)
                        .reflectListItemTransition(reduceMotion: reduceMotion)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                ReflectMotion.perform(reduceMotion: reduceMotion) {
                                    vm.delete(entry)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button("Edit", systemImage: "pencil") {
                                onEdit?(entry)
                            }
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                ReflectMotion.perform(reduceMotion: reduceMotion) {
                                    vm.delete(entry)
                                }
                            }
                        }

                        if index < group.entries.count - 1 {
                            Divider()
                                .padding(.leading, 34)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .reflectListItemTransition(reduceMotion: reduceMotion)
        .id(group.date)
    }

    // MARK: - Banners

    private var firstStoryBanner: some View {
        GlassCard(padding: 14, animate: false, moodTint: journalAmbientMood) {
            Label {
                Text("This is the first page of your story")
                    .font(.rf.headline)
                    .foregroundStyle(Color.rfTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            } icon: {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.rfAccentPrimary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("This is the first page of your story")
    }

    private var noResultsCard: some View {
        GlassCard(padding: 20, animate: false) {
            Text("No entries match your search.")
                .font(.rf.body)
                .foregroundStyle(Color.rfTextMuted)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
        }
        .accessibilityLabel("No entries match your search")
    }

    // MARK: - Empty State

    private var emptyStateScroll: some View {
        ScrollView {
            VStack {
                Spacer(minLength: 48)

                GlassCard(style: .elevated, padding: 28, animate: true) {
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.rfAccentSubtle)
                                .frame(width: 72, height: 72)
                            Image(systemName: "book.closed.fill")
                                .font(.rf.symbol)
                                .foregroundStyle(Color.rfAccentPrimary)
                        }
                        .accessibilityHidden(true)

                        VStack(spacing: 10) {
                            Text("Your Journal Is Empty (For Now)")
                                .font(.rf.title)
                                .foregroundStyle(Color.rfTextPrimary)
                                .multilineTextAlignment(.center)
                                .accessibilityAddTraits(.isHeader)

                            Text("Each check-in becomes a page in your story.")
                                .font(.rf.body)
                                .foregroundStyle(Color.rfTextMuted)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        PrimaryButton(title: "Log your first mood") {
                            onLogMood?()
                        }
                        .accessibilityLabel("Log your first mood")
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 28)
                .accessibilityElement(children: .contain)
                .accessibilityLabel(
                    "Your journal is empty for now. Each check-in becomes a page in your story."
                )

                Spacer(minLength: 80)
            }
        }
    }
}

// MARK: - Timeline

private struct JournalTimelineColumn: View {
    let isFirst: Bool
    let isLast: Bool
    let moodScore: Int

    private var dotColor: Color {
        MoodEntry(moodScore: moodScore).accentColor
    }

    var body: some View {
        VStack(spacing: 0) {
            if !isFirst {
                Rectangle()
                    .fill(Color.rfTextMuted.opacity(0.25))
                    .frame(width: 2, height: 8)
            } else {
                Color.clear.frame(width: 2, height: 8)
            }

            Circle()
                .fill(dotColor)
                .frame(width: 10, height: 10)
                .overlay(
                    Circle()
                        .strokeBorder(Color.rfCardBackground, lineWidth: 2)
                )
                .accessibilityHidden(true)

            if !isLast {
                Rectangle()
                    .fill(Color.rfTextMuted.opacity(0.25))
                    .frame(width: 2)
                    .frame(minHeight: 24)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 20)
    }
}

// MARK: - Entry Row

struct JournalEntryRow: View {
    let entry: MoodEntry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(entry.emoji)
                .font(.rf.emojiRow)
                .frame(minWidth: 36)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(entry.label)
                        .font(.rf.headline)
                        .foregroundStyle(Color.rfTextPrimary)
                        .layoutPriority(1)

                    Spacer(minLength: 8)

                    Text(entry.date, format: .dateTime.hour().minute())
                        .font(.rf.caption)
                        .foregroundStyle(Color.rfTextMuted)
                }

                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .font(.rf.body)
                        .foregroundStyle(Color.rfTextMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !entry.tags.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.rf.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .foregroundStyle(Color.rfTextPrimary)
                                .background(Color.rfAccentSubtle)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Swipe left to delete. Long press for more options.")
    }

    private var accessibilityDescription: String {
        var parts: [String] = []
        parts.append("\(entry.label), mood \(entry.moodScore) of 5")
        parts.append("at \(entry.date.formatted(date: .omitted, time: .shortened))")
        if let note = entry.note, !note.isEmpty {
            parts.append(note)
        }
        if !entry.tags.isEmpty {
            parts.append("Tags: \(entry.tags.joined(separator: ", "))")
        }
        return parts.joined(separator: ". ")
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Journal – With Entries") {
    JournalView(vm: JournalViewModel(store: DesignPreviewProvider.makePreviewMoodStore()))
}

#Preview("Journal – High Contrast") {
    JournalView(vm: JournalViewModel(store: DesignPreviewProvider.makeHighContrastMoodStore()))
}

#Preview("Journal – Empty") {
    JournalView(vm: JournalViewModel(store: MoodStore(previewEntries: [])))
}
#endif
