import Foundation
import SwiftUI

/// Drives the Journal screen — provides a filtered, grouped list of entries.
@Observable
final class JournalViewModel {
    var searchText: String = ""

    private let store: MoodStore

    init(store: MoodStore) {
        self.store = store
    }

    // MARK: - Derived Data

    var totalEntryCount: Int { store.entries.count }

    /// True when the user has logged exactly one check-in (post–guided onboarding).
    var isFirstStoryPage: Bool { totalEntryCount == 1 }

    var filteredEntries: [MoodEntry] {
        guard !searchText.isEmpty else { return store.entries }
        let query = searchText.lowercased()
        return store.entries.filter { entry in
            entry.tags.contains { $0.lowercased().contains(query) }
            || (entry.note?.lowercased().contains(query) ?? false)
            || entry.label.lowercased().contains(query)
        }
    }

    /// Entries grouped by calendar day, most recent first.
    var groupedByDay: [(date: Date, entries: [MoodEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        return grouped
            .map { (date: $0.key, entries: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Actions

    func delete(_ entry: MoodEntry) {
        store.delete(entry)
    }

    func delete(at offsets: IndexSet, in dayEntries: [MoodEntry]) {
        for index in offsets {
            store.delete(dayEntries[index])
        }
    }
}
