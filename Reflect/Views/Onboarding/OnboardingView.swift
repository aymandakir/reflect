import SwiftUI

/// Full-screen onboarding flow shown on first launch.
/// Three pages explain the value of mood tracking and how Reflect works,
/// ending with a "Get Started" button that dismisses the flow.
struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "heart.text.clipboard",
            title: "Why Track Your Mood?",
            body: "Studies show that simply noticing how you feel reduces stress and builds self-awareness. A few seconds of reflection each day can reveal patterns you never knew existed.",
            accent: Color.rfMoodHigh
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "How Reflect Works",
            body: "Quick check-ins let you score your mood, tag what matters, and jot a note. Your journal keeps everything organized, and Insights turns it into beautiful charts.",
            accent: Color.rfAccent
        ),
        OnboardingPage(
            icon: "figure.mind.and.body",
            title: "Your Journey Starts Now",
            body: "No sign-up, no cloud — your data stays on your device. Take a moment each day to check in, and watch the picture of your well-being come into focus.",
            accent: Color.rfMoodMid
        ),
    ]

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        pageView(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                bottomControls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
            }
        }
    }

    // MARK: - Page Content

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: page.icon)
                .font(.system(.largeTitle, design: .default).weight(.light))
                .imageScale(.large)
                .foregroundStyle(page.accent)
                .symbolEffect(.pulse, options: .repeating.speed(0.5))
                .frame(height: 90)
                .accessibilityHidden(true)

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.rf.title)
                    .foregroundStyle(Color.rfTextPrimary)
                    .multilineTextAlignment(.center)

                Text(page.body)
                    .font(.rf.body)
                    .foregroundStyle(Color.rfTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 16)

            Spacer()
            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 20) {
            pageIndicator

            if currentPage == pages.count - 1 {
                getStartedButton
            } else {
                nextButton
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.rfAccent : Color.rfAccent.opacity(0.25))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.35), value: currentPage)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentPage + 1) of \(pages.count)")
        .accessibilityValue(pages[currentPage].title)
    }

    private var nextButton: some View {
        Button {
            withAnimation { currentPage += 1 }
        } label: {
            Text("Next")
                .font(.rf.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.rfAccent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var getStartedButton: some View {
        Button(action: onFinish) {
            Text("Get Started")
                .font(.rf.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.rfAccent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.rfAccent.opacity(0.4), radius: 14, y: 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                pages[currentPage].accent.opacity(0.10),
                Color.rfBackground,
                Color.rfBackground,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .animation(.easeInOut(duration: 0.5), value: currentPage)
    }
}

// MARK: - Page Model

private struct OnboardingPage {
    let icon: String
    let title: String
    let body: String
    let accent: Color
}

// MARK: - Preview

#Preview {
    OnboardingView(onFinish: {})
}
