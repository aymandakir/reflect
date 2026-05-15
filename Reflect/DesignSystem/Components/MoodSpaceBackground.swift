import SwiftUI

/// Mood-reactive drifting orbs (no base fill — use with `ReflectBackground`).
struct MoodSpaceOrbs: View {
    var moodScore: Int = 3
    var subdued: Bool = false

    private var accent: Color { MoodEntry(moodScore: moodScore).accentColor }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack {
                    moodOrb(
                        color: accent.opacity(subdued ? 0.2 : 0.34),
                        size: w * 0.85,
                        x: w * 0.2 + sin(t * 0.35) * 28,
                        y: h * 0.15 + cos(t * 0.28) * 22
                    )
                    moodOrb(
                        color: Color.rfAccentPrimary.opacity(subdued ? 0.1 : 0.18),
                        size: w * 0.65,
                        x: w * 0.75 + cos(t * 0.42) * 24,
                        y: h * 0.45 + sin(t * 0.33) * 26
                    )
                    moodOrb(
                        color: Color.rfMoodHigh.opacity(subdued ? 0.06 : 0.12),
                        size: w * 0.5,
                        x: w * 0.45 + sin(t * 0.25) * 18,
                        y: h * 0.78 + cos(t * 0.38) * 20
                    )
                }
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.8), value: moodScore)
        .accessibilityHidden(true)
    }

    private func moodOrb(color: Color, size: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: size * 0.28)
            .position(x: x, y: y)
    }
}

/// Backward-compatible full-screen mood background (aurora + orbs).
struct MoodSpaceBackground: View {
    var moodScore: Int = 3
    var subdued: Bool = false

    var body: some View {
        ReflectBackground(moodScore: moodScore, subdued: subdued) {
            Color.clear
        }
    }
}
