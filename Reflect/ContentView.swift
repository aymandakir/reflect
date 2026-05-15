import SwiftUI

/// Root view — tab bar with Check-In, Journal, and Insights.
/// First launch uses guided check-in layered on CheckInView (not a separate carousel).
struct ContentView: View {
    var store: MoodStore

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("showInsightsOnboardingPreview") private var showInsightsOnboardingPreview = false

    @State private var selectedTab: Tab = .checkIn
    @State private var guidedController: GuidedCheckInController?
    @State private var checkInVM: CheckInViewModel?
    @State private var journalVM: JournalViewModel?
    @State private var insightsVM: InsightsViewModel?

    enum Tab: String {
        case checkIn  = "Check In"
        case journal  = "Journal"
        case insights = "Insights"
    }

    private var isGuidedActive: Bool {
        !hasCompletedOnboarding && guidedController != nil
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                SwiftUI.Tab(Tab.checkIn.rawValue, systemImage: "plus.circle.fill", value: .checkIn) {
                    CheckInView(
                        vm: makeCheckInVM(),
                        guided: guidedController,
                        onGuidedSkip: completeOnboarding,
                        onGuidedFinish: finishGuidedCheckIn
                    )
                }

                SwiftUI.Tab(Tab.journal.rawValue, systemImage: "book.fill", value: .journal) {
                    JournalView(vm: makeJournalVM(), onEdit: { entry in
                        makeCheckInVM().beginEditing(entry)
                        selectedTab = .checkIn
                    }, onLogMood: {
                        selectedTab = .checkIn
                    })
                }

                SwiftUI.Tab(Tab.insights.rawValue, systemImage: "chart.xyaxis.line", value: .insights) {
                    InsightsView(
                        vm: makeInsightsVM(),
                        showOnboardingPreview: showInsightsOnboardingPreview,
                        onLogMood: { selectedTab = .checkIn },
                        onDismissPreview: { showInsightsOnboardingPreview = false }
                    )
                }
            }
            .tint(Color.rfAccentPrimary)
            .onChange(of: selectedTab) { _, newTab in
                guard isGuidedActive else { return }
                if newTab != .checkIn {
                    selectedTab = .checkIn
                }
            }

            if isGuidedActive {
                tabBarDimmingOverlay
            }
        }
        .onAppear {
            if !hasCompletedOnboarding, guidedController == nil {
                guidedController = GuidedCheckInController()
                selectedTab = .checkIn
                AccessibilityNotification.Announcement(
                    "Welcome to Reflect. Guided first check-in. Step 1 of 3."
                ).post()
            }
        }
    }

    private var tabBarDimmingOverlay: some View {
        LinearGradient(
            colors: [Color.black.opacity(0), Color.black.opacity(0.45)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 100)
        .allowsHitTesting(true)
        .accessibilityHidden(true)
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
        guidedController = nil
        AccessibilityNotification.Announcement("Guided tour skipped.").post()
    }

    private func finishGuidedCheckIn(destination: Tab) {
        hasCompletedOnboarding = true
        guidedController = nil
        if destination == .insights {
            showInsightsOnboardingPreview = true
        }
        selectedTab = destination
    }

    private func makeCheckInVM() -> CheckInViewModel {
        if let existing = checkInVM { return existing }
        let vm = CheckInViewModel(store: store)
        checkInVM = vm
        return vm
    }

    private func makeJournalVM() -> JournalViewModel {
        if let existing = journalVM { return existing }
        let vm = JournalViewModel(store: store)
        journalVM = vm
        return vm
    }

    private func makeInsightsVM() -> InsightsViewModel {
        if let existing = insightsVM { return existing }
        let vm = InsightsViewModel(store: store)
        insightsVM = vm
        return vm
    }
}

#Preview {
    ContentView(store: MoodStore())
}
