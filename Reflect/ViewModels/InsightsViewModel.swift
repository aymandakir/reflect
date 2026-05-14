import Foundation
import SwiftUI

/// Drives the Insights screen — computes aggregated mood data for charts.
@Observable
final class InsightsViewModel {
    var selectedRange: DateRange = .week

    private let store: MoodStore

    init(store: MoodStore) {
        self.store = store
    }

    // MARK: - Date Range

    enum DateRange: String, CaseIterable, Identifiable {
        case week   = "7 Days"
        case month  = "30 Days"
        case quarter = "90 Days"

        var id: String { rawValue }
        var days: Int {
            switch self {
            case .week:    return 7
            case .month:   return 30
            case .quarter: return 90
            }
        }
    }

    // MARK: - Chart Data

    /// One data point per day within the selected range.
    struct DayPoint: Identifiable {
        let id = UUID()
        let date: Date
        let averageScore: Double
        let entryCount: Int
    }

    var chartData: [DayPoint] {
        let calendar = Calendar.current
        let recent = store.entries(lastDays: selectedRange.days)
        let grouped = Dictionary(grouping: recent) { entry in
            calendar.startOfDay(for: entry.date)
        }

        return (0..<selectedRange.days).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: .now)) else {
                return nil
            }
            let dayEntries = grouped[day] ?? []
            let avg = dayEntries.isEmpty
                ? 0
                : Double(dayEntries.reduce(0) { $0 + $1.moodScore }) / Double(dayEntries.count)
            return DayPoint(date: day, averageScore: avg, entryCount: dayEntries.count)
        }
        .reversed()
    }

    // MARK: - Summary Stats

    var averageMood: Double? {
        store.averageMood(lastDays: selectedRange.days)
    }

    var totalEntries: Int {
        store.entries(lastDays: selectedRange.days).count
    }

    var streakDays: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: .now)

        while store.entries.contains(where: { calendar.isDate($0.date, inSameDayAs: checkDate) }) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        return streak
    }

    /// Most frequently used tags in the selected range.
    var topTags: [(tag: String, count: Int)] {
        let recent = store.entries(lastDays: selectedRange.days)
        var freq: [String: Int] = [:]
        for entry in recent {
            for tag in entry.tags {
                freq[tag, default: 0] += 1
            }
        }
        return freq
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { (tag: $0.key, count: $0.value) }
    }
}
