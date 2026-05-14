import Foundation
import SwiftUI

/// Drives the Check-in screen — handles creating and editing mood entries.
@Observable
final class CheckInViewModel {
    // MARK: - Form State

    var moodScore: Int = 3
    var note: String = ""
    var selectedTags: Set<String> = []
    var isEditing: Bool = false
    var showConfirmation: Bool = false

    /// The entry being edited (nil for new entries).
    private var editingEntry: MoodEntry?

    /// Suggested tags the user can pick from.
    let availableTags: [String] = [
        "work", "exercise", "friends", "family",
        "stress", "reading", "meditation", "outdoors",
        "cooking", "music", "travel", "health"
    ]

    private let store: MoodStore

    init(store: MoodStore) {
        self.store = store
    }

    // MARK: - Actions

    func save() {
        if let existing = editingEntry {
            var updated = existing
            updated.moodScore = moodScore
            updated.note = note.isEmpty ? nil : note
            updated.tags = Array(selectedTags)
            store.update(updated)
        } else {
            let entry = MoodEntry(
                moodScore: moodScore,
                tags: Array(selectedTags),
                note: note.isEmpty ? nil : note
            )
            store.add(entry)
        }
        showConfirmation = true
        resetForm()
    }

    func beginEditing(_ entry: MoodEntry) {
        editingEntry = entry
        moodScore = entry.moodScore
        note = entry.note ?? ""
        selectedTags = Set(entry.tags)
        isEditing = true
    }

    func cancelEditing() {
        resetForm()
    }

    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    private func resetForm() {
        editingEntry = nil
        moodScore = 3
        note = ""
        selectedTags = []
        isEditing = false
    }
}
