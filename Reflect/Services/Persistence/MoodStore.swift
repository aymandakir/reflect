import Foundation
import SwiftUI

/// Persistence layer for mood entries.
///
/// Current implementation: writes JSON to the app's documents directory.
/// Future: swap in SwiftData, Core Data, or CloudKit without touching ViewModels.
@Observable
final class MoodStore {
    private(set) var entries: [MoodEntry] = []

    private let fileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appending(path: "mood_entries.json")
    }()

    init() {
        load()
    }

    // MARK: - CRUD

    func add(_ entry: MoodEntry) {
        entries.append(entry)
        entries.sort { $0.date > $1.date }
        save()
    }

    func update(_ entry: MoodEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        entries.sort { $0.date > $1.date }
        save()
    }

    func delete(_ entry: MoodEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    // MARK: - Queries

    /// Entries from the last N days, sorted oldest-first (useful for charts).
    func entries(lastDays days: Int) -> [MoodEntry] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: .now)!
        return entries
            .filter { $0.date >= cutoff }
            .sorted { $0.date < $1.date }
    }

    /// Average mood score over the last N days. Returns nil if no data.
    func averageMood(lastDays days: Int) -> Double? {
        let recent = entries(lastDays: days)
        guard !recent.isEmpty else { return nil }
        let sum = recent.reduce(0) { $0 + $1.moodScore }
        return Double(sum) / Double(recent.count)
    }

    // MARK: - Persistence (JSON file)

    private func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("[MoodStore] Save failed: \(error.localizedDescription)")
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path()) else {
            entries = []
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            entries = try JSONDecoder().decode([MoodEntry].self, from: data)
            entries.sort { $0.date > $1.date }
        } catch {
            print("[MoodStore] Load failed: \(error.localizedDescription)")
            entries = []
        }
    }

    // MARK: - Debug

    /// Resets to sample data (useful for previews / testing).
    func resetToSampleData() {
        entries = MoodEntry.sampleEntries
        save()
    }
}
