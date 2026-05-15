#if DEBUG
import Foundation

/// Seeds rich in-memory data for SwiftUI previews and portfolio screenshots.
/// Not used in production builds.
enum DesignPreviewProvider {
    private static let tagPool = [
        "work", "exercise", "friends", "family",
        "stress", "reading", "meditation", "outdoors",
        "cooking", "music", "travel", "health",
    ]

    private static let notePool = [
        "Slow morning, but the afternoon opened up.",
        "Back-to-back meetings — grateful for a walk afterward.",
        "Caught up with an old friend over coffee.",
        "Quiet evening with a book and tea.",
        "Felt scattered at first; journaling helped.",
        "Sunlight through the window made everything softer.",
        "Pushed through a tough task and felt lighter after.",
        "Body felt tired; mind felt calm.",
        "Small win today — finished something I'd been avoiding.",
        "Overwhelmed briefly, then breathed and reset.",
        "A good laugh at dinner turned the day around.",
        "Needed more rest than I planned. That's okay.",
        nil,
        nil,
    ]

    /// ~25 entries across 30 days with a 7-day recent streak (portfolio default).
    static func makePreviewMoodStore() -> MoodStore {
        MoodStore(previewEntries: buildEntries(highContrast: false))
    }

    /// Same timeline with bolder mood swings for light/dark screenshot contrast.
    static func makeHighContrastMoodStore() -> MoodStore {
        MoodStore(previewEntries: buildEntries(highContrast: true))
    }

    /// Empty store — matches first-launch check-in before any save.
    static func makeEmptyMoodStore() -> MoodStore {
        MoodStore(previewEntries: [])
    }

    /// Sample entry for guided summary / completion previews.
    static func sampleFirstCheckInEntry() -> MoodEntry {
        MoodEntry(
            moodScore: 4,
            tags: ["friends", "outdoors"],
            note: "A quiet morning that turned into a good day."
        )
    }

    /// Guided onboarding controller frozen at a specific step.
    static func guidedController(
        step: GuidedCheckInController.GuidedCheckInStep,
        savedEntry: MoodEntry? = nil
    ) -> GuidedCheckInController {
        let controller = GuidedCheckInController()
        controller.step = step
        controller.savedEntry = savedEntry ?? (step == .summary ? sampleFirstCheckInEntry() : nil)
        return controller
    }

    // MARK: - Entry builder

    private static func buildEntries(highContrast: Bool) -> [MoodEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        var entries: [MoodEntry] = []
        var seed = 0

        func nextScore(dayIndex: Int) -> Int {
            if highContrast {
                let pattern = [5, 2, 4, 1, 5, 3, 4, 2, 5, 1]
                return pattern[seed % pattern.count]
            }
            let pattern = [4, 3, 5, 3, 4, 2, 4, 5, 3, 4, 3, 5, 4, 2, 3]
            return pattern[(dayIndex + seed) % pattern.count]
        }

        func entry(
            dayOffset: Int,
            hour: Int,
            minute: Int,
            score: Int,
            tagCount: Int
        ) {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: today),
                  let date = calendar.date(
                    bySettingHour: hour,
                    minute: minute,
                    second: 0,
                    of: day
                  ) else { return }

            let tags = Array(tagPool.shuffled().prefix(tagCount))
            let note = notePool[seed % notePool.count]
            seed += 1

            entries.append(
                MoodEntry(
                    date: date,
                    moodScore: score,
                    tags: tags,
                    note: note
                )
            )
        }

        // Recent streak: one check-in per day for the last 7 days (including today).
        let streakHours = [8, 21, 19, 12, 20, 9, 18]
        for day in 0..<7 {
            entry(
                dayOffset: day,
                hour: streakHours[day % streakHours.count],
                minute: (day * 11) % 60,
                score: nextScore(dayIndex: day),
                tagCount: day.isMultiple(of: 2) ? 2 : 1
            )
        }

        // Older history: 18 more entries scattered across days 8–29.
        let scatterDays = [8, 9, 11, 12, 14, 15, 17, 18, 20, 21, 23, 24, 25, 26, 28, 29, 10, 16]
        let scatterTimes: [(Int, Int)] = [
            (7, 30), (22, 15), (13, 45), (18, 0), (10, 20),
            (21, 50), (8, 10), (16, 35), (19, 25), (11, 5),
            (20, 40), (14, 55), (9, 15), (17, 10), (12, 30),
            (23, 0), (15, 45), (6, 50),
        ]

        for (index, day) in scatterDays.enumerated() {
            let time = scatterTimes[index % scatterTimes.count]
            entry(
                dayOffset: day,
                hour: time.0,
                minute: time.1,
                score: nextScore(dayIndex: day + index),
                tagCount: index.isMultiple(of: 3) ? 3 : (index.isMultiple(of: 2) ? 2 : 1)
            )
        }

        return entries
    }
}
#endif
