import SwiftUI

/// Root view — a tab bar with Check-In, Journal, and Insights.
/// Shows a full-screen onboarding flow on first launch.
struct ContentView: View {
    var store: MoodStore

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false
    @State private var selectedTab: Tab = .checkIn
    @State private var checkInVM: CheckInViewModel?
    @State private var journalVM: JournalViewModel?
    @State private var insightsVM: InsightsViewModel?

    enum Tab: String {
        case checkIn  = "Check In"
        case journal  = "Journal"
        case insights = "Insights"
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            SwiftUI.Tab(Tab.checkIn.rawValue, systemImage: "plus.circle.fill", value: .checkIn) {
                CheckInView(vm: makeCheckInVM())
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
                InsightsView(vm: makeInsightsVM(), onLogMood: {
                    selectedTab = .checkIn
                })
            }
        }
        .tint(Color.rfAccent)
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                hasCompletedOnboarding = true
                showOnboarding = false
                selectedTab = .checkIn
            }
        }
        .onAppear {
            if !hasCompletedOnboarding {
                showOnboarding = true
            }
        }
    }

    // Lazy ViewModel creation — each VM is created once and reused.

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

// MARK: - Preview

#Preview {
    ContentView(store: MoodStore())
}
