import SwiftUI

/// Scrollable list of all mood entries, grouped by day, with search and swipe-to-delete.
struct JournalView: View {
    @Bindable var vm: JournalViewModel
    var onEdit: ((MoodEntry) -> Void)?
    var onLogMood: (() -> Void)?

    var body: some View {
        NavigationStack {
            Group {
                if vm.filteredEntries.isEmpty {
                    emptyState
                } else {
                    entryList
                }
            }
            .background(backgroundGradient)
            .navigationTitle("Journal")
            .searchable(text: $vm.searchText, prompt: "Search tags or notes…")
        }
    }

    // MARK: - Entry List

    private var entryList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(vm.groupedByDay, id: \.date) { group in
                    Section {
                        ForEach(group.entries) { entry in
                            JournalEntryRow(entry: entry)
                                .glassCard(cornerRadius: 20, padding: 16)
                                .contextMenu {
                                    Button("Edit", systemImage: "pencil") {
                                        onEdit?(entry)
                                    }
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        withAnimation { vm.delete(entry) }
                                    }
                                }
                        }
                    } header: {
                        Text(group.date, format: .dateTime.weekday(.wide).month().day())
                            .font(.rf.caption)
                            .foregroundStyle(Color.rfTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 4)
                            .padding(.top, 8)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "book.closed")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(Color.rfAccent.opacity(0.5))

            VStack(spacing: 10) {
                Text("Your Journal Is Empty")
                    .font(.rf.title2)
                    .foregroundStyle(Color.rfTextPrimary)

                Text("Every journey starts with a single step.\nLog your first mood and start building\na picture of your well-being.")
                    .font(.rf.body)
                    .foregroundStyle(Color.rfTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            Button {
                onLogMood?()
            } label: {
                Label("Log a Mood", systemImage: "plus.circle.fill")
                    .font(.rf.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(Color.rfAccent, in: Capsule())
                    .shadow(color: Color.rfAccent.opacity(0.3), radius: 10, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private var backgroundGradient: some View {
        Color.rfBackground.ignoresSafeArea()
    }
}

// MARK: - Entry Row

struct JournalEntryRow: View {
    let entry: MoodEntry

    var body: some View {
        HStack(spacing: 14) {
            Text(entry.emoji)
                .font(.system(size: 36))
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.label)
                        .font(.rf.headline)
                        .foregroundStyle(Color.rfTextPrimary)

                    Spacer()

                    Text(entry.date, format: .dateTime.hour().minute())
                        .font(.rf.caption)
                        .foregroundStyle(Color.rfTextSecondary)
                }

                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .font(.rf.subhead)
                        .foregroundStyle(Color.rfTextSecondary)
                        .lineLimit(2)
                }

                if !entry.tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.rf.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.rfAccentSoft)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    JournalView(vm: JournalViewModel(store: MoodStore()))
}
