import SwiftUI
import Charts

/// Visual insights — mood trend chart, summary stats, and top tags.
struct InsightsView: View {
    @Bindable var vm: InsightsViewModel
    var showOnboardingPreview: Bool = false
    var onLogMood: (() -> Void)?
    var onDismissPreview: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var chartRevealed = false

    private var statsStackVertically: Bool {
        ReflectAccessibility.isAccessibilitySize(dynamicTypeSize)
    }

    private var ambientMoodScore: Int {
        Int((vm.averageMood ?? 3).rounded())
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.hasNoEntries {
                    emptyStateScroll
                } else {
                    dataScroll
                }
            }
            .reflectBackground(
                moodScore: ambientMoodScore,
                subdued: vm.hasNoEntries,
                variant: .dashboard
            )
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Data

    private var dataScroll: some View {
        ScrollView {
            VStack(spacing: 20) {
                if vm.isFirstStoryPage {
                    firstStoryBanner
                } else if showOnboardingPreview {
                    onboardingPreviewBanner
                }

                rangePickerCard
                moodChartCard
                statsRow
                topTagsCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Banners

    private var firstStoryBanner: some View {
        GlassCard(padding: 14, animate: false, moodTint: ambientMoodScore) {
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

    private var onboardingPreviewBanner: some View {
        GlassCard(padding: 16, moodTint: ambientMoodScore) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Your story is starting")
                        .font(.rf.headline)
                        .foregroundStyle(Color.rfTextPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    if onDismissPreview != nil {
                        Button {
                            onDismissPreview?()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.rfTextMuted)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Dismiss preview banner")
                    }
                }

                Text("As you log more check-ins, this space fills with trends, streaks, and patterns — a gentle mirror of how you've been feeling.")
                    .font(.rf.body)
                    .foregroundStyle(Color.rfTextMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .contain)
    }

    // MARK: - Range Picker

    private var rangePickerCard: some View {
        GlassCard(padding: 12, animate: false) {
            Picker("Range", selection: $vm.selectedRange) {
                ForEach(InsightsViewModel.DateRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Date range")
        }
    }

    // MARK: - Mood Chart

    private var moodChartCard: some View {
        GlassCard(moodTint: ambientMoodScore) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Mood Over Time")
                    .font(.rf.headline)
                    .foregroundStyle(Color.rfTextPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text("How your check-ins trend across the selected period.")
                    .font(.rf.caption)
                    .foregroundStyle(Color.rfTextMuted)
                    .fixedSize(horizontal: false, vertical: true)

                if vm.chartData.contains(where: { $0.averageScore > 0 }) {
                    moodChart
                } else {
                    Text("No data for this period.")
                        .font(.rf.body)
                        .foregroundStyle(Color.rfTextMuted)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("No mood data for this period")
                }
            }
        }
    }

    private var moodChart: some View {
        Chart(vm.chartData) { point in
            if point.averageScore > 0 {
                LineMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Mood", point.averageScore)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.rfAccentPrimary)
                .lineStyle(StrokeStyle(lineWidth: 2.5))

                AreaMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Mood", point.averageScore)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.rfAccentPrimary.opacity(0.18),
                            Color.rfAccentPrimary.opacity(0.0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                PointMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Mood", point.averageScore)
                )
                .foregroundStyle(Color.rfAccentPrimary)
                .symbolSize(point.entryCount > 0 ? 36 : 0)
            }
        }
        .chartYScale(domain: 0.5...5.5)
        .chartYAxis {
            AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                AxisValueLabel {
                    if let intVal = value.as(Int.self) {
                        Text(MoodEntry(moodScore: intVal).emoji)
                            .font(.rf.caption)
                    }
                }
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .foregroundStyle(Color.rfTextMuted.opacity(0.25))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: vm.selectedRange == .week ? 1 : 7)) { _ in
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .font(.rf.caption)
                    .foregroundStyle(Color.rfTextMuted)
                AxisGridLine()
                    .foregroundStyle(Color.rfTextMuted.opacity(0.12))
            }
        }
        .frame(height: 200)
        .mask {
            if reduceMotion {
                Rectangle()
            } else {
                GeometryReader { geo in
                    Rectangle()
                        .frame(width: chartRevealed ? geo.size.width : 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .onAppear { revealChart() }
        .onChange(of: vm.selectedRange) { _, _ in revealChart() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(chartAccessibilityLabel)
    }

    private func revealChart() {
        chartRevealed = false
        if reduceMotion {
            chartRevealed = true
            return
        }
        withAnimation(ReflectMotion.chartReveal(reduceMotion: false)) {
            chartRevealed = true
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("At a glance")
                .font(.rf.caption)
                .foregroundStyle(Color.rfTextMuted)
                .textCase(.uppercase)
                .tracking(0.8)
                .padding(.leading, 4)
                .accessibilityAddTraits(.isHeader)

            Group {
                if statsStackVertically {
                    VStack(spacing: 12) { statCards }
                } else {
                    HStack(alignment: .top, spacing: 12) { statCards }
                }
            }
        }
    }

    @ViewBuilder
    private var statCards: some View {
        StatCard(
            title: "Average",
            value: averageFormatted,
            icon: "chart.bar.fill",
            accentIcon: true,
            voiceOverLabel: "Average mood last \(vm.selectedRange.rawValue): \(averageFormatted)"
        )
        StatCard(
            title: "Entries",
            value: "\(vm.totalEntries)",
            icon: "list.bullet",
            voiceOverLabel: "\(vm.totalEntries) entries in last \(vm.selectedRange.rawValue)"
        )
        StatCard(
            title: "Streak",
            value: "\(vm.streakDays)d",
            icon: "flame.fill",
            voiceOverLabel: "Current streak: \(vm.streakDays) days"
        )
    }

    private var averageFormatted: String {
        guard let avg = vm.averageMood else { return "—" }
        return String(format: "%.1f", avg)
    }

    // MARK: - Top Tags

    private var topTagsCard: some View {
        GlassCard(moodTint: ambientMoodScore) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Top Tags")
                    .font(.rf.headline)
                    .foregroundStyle(Color.rfTextPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text("What shows up most in your check-ins.")
                    .font(.rf.caption)
                    .foregroundStyle(Color.rfTextMuted)

                if vm.topTags.isEmpty {
                    Text("No tags recorded yet.")
                        .font(.rf.body)
                        .foregroundStyle(Color.rfTextMuted)
                        .padding(.top, 4)
                } else {
                    ForEach(vm.topTags, id: \.tag) { item in
                        HStack {
                            Text(item.tag)
                                .font(.rf.body)
                                .foregroundStyle(Color.rfTextPrimary)
                            Spacer()
                            Text("\(item.count)×")
                                .font(.rf.caption)
                                .foregroundStyle(Color.rfTextMuted)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(item.tag), used \(item.count) \(item.count == 1 ? "time" : "times")")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var chartAccessibilityLabel: String {
        let filled = vm.chartData.filter { $0.averageScore > 0 }
        guard !filled.isEmpty else { return "Mood chart, no data" }
        let scores = filled.map(\.averageScore)
        let avg = scores.reduce(0, +) / Double(scores.count)
        let lo = scores.min() ?? 0
        let hi = scores.max() ?? 0
        return "Mood chart for last \(vm.selectedRange.rawValue). Average \(String(format: "%.1f", avg)), low \(String(format: "%.1f", lo)), high \(String(format: "%.1f", hi)), across \(filled.count) days"
    }

    // MARK: - Empty State

    private var emptyStateScroll: some View {
        ScrollView {
            VStack {
                Spacer(minLength: 40)

                GlassCard(style: .elevated, padding: 28, animate: true) {
                    VStack(spacing: 22) {
                        InsightsPlaceholderChart()
                            .frame(height: 120)
                            .accessibilityHidden(true)

                        VStack(spacing: 10) {
                            Text("No Insights Yet")
                                .font(.rf.title)
                                .foregroundStyle(Color.rfTextPrimary)
                                .accessibilityAddTraits(.isHeader)

                            Text("As you check in, Reflect turns your moods into patterns you can understand.")
                                .font(.rf.body)
                                .foregroundStyle(Color.rfTextMuted)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        PrimaryButton(title: "Log a mood") {
                            onLogMood?()
                        }
                        .accessibilityLabel("Log a mood")
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 28)
                .accessibilityElement(children: .contain)
                .accessibilityLabel(
                    "No insights yet. As you check in, Reflect turns your moods into patterns you can understand."
                )

                Spacer(minLength: 80)
            }
        }
    }
}

// MARK: - Placeholder chart (empty state)

private struct InsightsPlaceholderChart: View {
    private let points: [CGPoint] = [
        CGPoint(x: 0.08, y: 0.55),
        CGPoint(x: 0.28, y: 0.38),
        CGPoint(x: 0.48, y: 0.62),
        CGPoint(x: 0.68, y: 0.42),
        CGPoint(x: 0.88, y: 0.58),
    ]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                ForEach(0..<4, id: \.self) { i in
                    Path { path in
                        let y = h * CGFloat(i + 1) / 5
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: w, y: y))
                    }
                    .stroke(Color.rfTextMuted.opacity(0.12), style: StrokeStyle(lineWidth: 1, dash: [4, 6]))
                }

                Path { path in
                    guard let first = points.first else { return }
                    path.move(to: CGPoint(x: first.x * w, y: first.y * h))
                    for point in points.dropFirst() {
                        path.addLine(to: CGPoint(x: point.x * w, y: point.y * h))
                    }
                }
                .stroke(Color.rfAccentPrimary.opacity(0.35), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                    Circle()
                        .fill(Color.rfAccentPrimary.opacity(0.45))
                        .frame(width: 8, height: 8)
                        .position(x: point.x * w, y: point.y * h)
                }
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var accentIcon: Bool = false
    var voiceOverLabel: String? = nil

    var body: some View {
        GlassCard(padding: 14, animate: false) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.rf.headline)
                    .foregroundStyle(accentIcon ? Color.rfAccentPrimary : Color.rfTextMuted)
                    .accessibilityHidden(true)

                Text(value)
                    .font(.rf.number)
                    .foregroundStyle(Color.rfTextPrimary)
                    .minimumScaleFactor(0.75)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(title)
                    .font(.rf.caption)
                    .foregroundStyle(Color.rfTextMuted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(voiceOverLabel ?? "\(title): \(value)")
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Insights – Full Chart") {
    InsightsView(vm: InsightsViewModel(store: DesignPreviewProvider.makePreviewMoodStore()))
}

#Preview("Insights – High Contrast") {
    InsightsView(vm: InsightsViewModel(store: DesignPreviewProvider.makeHighContrastMoodStore()))
}

#Preview("Insights – Empty") {
    InsightsView(vm: InsightsViewModel(store: MoodStore(previewEntries: [])))
}
#endif
