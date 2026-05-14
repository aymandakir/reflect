import SwiftUI
import Charts

/// Visual insights — mood trend chart, summary stats, and top tags.
struct InsightsView: View {
    @Bindable var vm: InsightsViewModel
    var onLogMood: (() -> Void)?

    var body: some View {
        NavigationStack {
            Group {
                if vm.hasNoEntries {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            rangePicker
                            moodChart
                            statsRow
                            topTagsCard
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
            .background(backgroundGradient)
            .navigationTitle("Insights")
        }
    }

    // MARK: - Range Picker

    private var rangePicker: some View {
        Picker("Range", selection: $vm.selectedRange) {
            ForEach(InsightsViewModel.DateRange.allCases) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding(.top, 8)
    }

    // MARK: - Mood Chart

    private var moodChart: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Mood Over Time")
                    .font(.rf.headline)
                    .foregroundStyle(Color.rfTextPrimary)

                if vm.chartData.contains(where: { $0.averageScore > 0 }) {
                    Chart(vm.chartData) { point in
                        if point.averageScore > 0 {
                            LineMark(
                                x: .value("Date", point.date, unit: .day),
                                y: .value("Mood", point.averageScore)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(Color.rfAccent)

                            AreaMark(
                                x: .value("Date", point.date, unit: .day),
                                y: .value("Mood", point.averageScore)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.rfAccent.opacity(0.3), Color.rfAccent.opacity(0.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                            PointMark(
                                x: .value("Date", point.date, unit: .day),
                                y: .value("Mood", point.averageScore)
                            )
                            .foregroundStyle(Color.rfAccent)
                            .symbolSize(30)
                        }
                    }
                    .chartYScale(domain: 0.5...5.5)
                    .chartYAxis {
                        AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                            AxisValueLabel {
                                if let intVal = value.as(Int.self) {
                                    Text(MoodEntry(moodScore: intVal).emoji)
                                        .font(.rf.caption2)
                                }
                            }
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                                .foregroundStyle(Color.rfTextSecondary.opacity(0.3))
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: vm.selectedRange == .week ? 1 : 7)) { _ in
                            AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                .font(.rf.caption2)
                            AxisGridLine()
                                .foregroundStyle(Color.rfTextSecondary.opacity(0.15))
                        }
                    }
                    .frame(height: 200)
                } else {
                    Text("No data for this period.")
                        .font(.rf.body)
                        .foregroundStyle(Color.rfTextSecondary)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(title: "Average", value: averageFormatted, icon: "chart.bar.fill")
            StatCard(title: "Entries", value: "\(vm.totalEntries)", icon: "list.bullet")
            StatCard(title: "Streak", value: "\(vm.streakDays)d", icon: "flame.fill")
        }
    }

    private var averageFormatted: String {
        guard let avg = vm.averageMood else { return "—" }
        return String(format: "%.1f", avg)
    }

    // MARK: - Top Tags

    private var topTagsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Top Tags")
                    .font(.rf.headline)
                    .foregroundStyle(Color.rfTextPrimary)

                if vm.topTags.isEmpty {
                    Text("No tags recorded yet.")
                        .font(.rf.body)
                        .foregroundStyle(Color.rfTextSecondary)
                } else {
                    ForEach(vm.topTags, id: \.tag) { item in
                        HStack {
                            Text(item.tag)
                                .font(.rf.body)
                                .foregroundStyle(Color.rfTextPrimary)
                            Spacer()
                            Text("\(item.count)×")
                                .font(.rf.caption)
                                .foregroundStyle(Color.rfTextSecondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(Color.rfAccent.opacity(0.5))

            VStack(spacing: 10) {
                Text("No Insights Yet")
                    .font(.rf.title2)
                    .foregroundStyle(Color.rfTextPrimary)

                Text("Once you start logging moods, Reflect will\nreveal trends, streaks, and patterns to help\nyou understand yourself better.")
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

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.rfMoodHigh.opacity(0.06), Color.rfBackground],
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .ignoresSafeArea()
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        GlassCard(cornerRadius: 18, padding: 14) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.rf.title3)
                    .foregroundStyle(Color.rfAccent)

                Text(value)
                    .font(.rf.title2)
                    .foregroundStyle(Color.rfTextPrimary)

                Text(title)
                    .font(.rf.caption)
                    .foregroundStyle(Color.rfTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview

#Preview {
    InsightsView(vm: InsightsViewModel(store: MoodStore()))
}
