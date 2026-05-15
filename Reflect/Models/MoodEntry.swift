import Foundation
import SwiftUI

/// A single mood journal entry captured during a check-in.
struct MoodEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    /// Score from 1 (very low) to 5 (excellent).
    var moodScore: Int
    var tags: [String]
    var note: String?

    init(
        id: UUID = UUID(),
        date: Date = .now,
        moodScore: Int = 3,
        tags: [String] = [],
        note: String? = nil
    ) {
        self.id = id
        self.date = date
        self.moodScore = Self.clamp(moodScore)
        self.tags = tags
        self.note = note
    }

    // MARK: - Helpers

    /// Human-readable emoji for the mood score.
    var emoji: String {
        switch moodScore {
        case 1: return "😞"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }

    /// Display label for the mood score.
    var label: String {
        switch moodScore {
        case 1: return "Awful"
        case 2: return "Bad"
        case 3: return "Okay"
        case 4: return "Good"
        case 5: return "Great"
        default: return "Okay"
        }
    }

    /// Accent used for mood-reactive backgrounds and glass tints.
    var accentColor: Color {
        switch moodScore {
        case 1: return .rfMoodLow
        case 2: return Color(hex: "FF9F6B")
        case 3: return .rfMoodMid
        case 4: return Color(hex: "8FD9A8")
        case 5: return .rfMoodHigh
        default: return .rfAccentPrimary
        }
    }

    private static func clamp(_ value: Int) -> Int {
        min(max(value, 1), 5)
    }
}

// MARK: - Sample Data

extension MoodEntry {
    static let sampleEntries: [MoodEntry] = [
        MoodEntry(date: Calendar.current.date(byAdding: .day, value: -6, to: .now)!, moodScore: 3, tags: ["work"], note: "Regular day at the office."),
        MoodEntry(date: Calendar.current.date(byAdding: .day, value: -5, to: .now)!, moodScore: 4, tags: ["exercise", "friends"], note: "Great run in the park."),
        MoodEntry(date: Calendar.current.date(byAdding: .day, value: -4, to: .now)!, moodScore: 2, tags: ["stress"], note: "Deadline pressure."),
        MoodEntry(date: Calendar.current.date(byAdding: .day, value: -3, to: .now)!, moodScore: 5, tags: ["family", "outdoors"], note: "Beach day with family!"),
        MoodEntry(date: Calendar.current.date(byAdding: .day, value: -2, to: .now)!, moodScore: 4, tags: ["reading"], note: nil),
        MoodEntry(date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!, moodScore: 3, tags: ["work", "cooking"], note: "Tried a new recipe."),
        MoodEntry(date: .now, moodScore: 4, tags: ["meditation"], note: "Morning meditation felt amazing."),
    ]
}
