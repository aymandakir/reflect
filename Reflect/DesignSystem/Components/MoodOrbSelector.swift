import SwiftUI

/// Mood score picker with a central orb and glowing score rings.
struct MoodOrbSelector: View {
    @Binding var moodScore: Int
    var onScoreChange: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false

    private var mood: MoodEntry { MoodEntry(moodScore: moodScore) }

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [mood.accentColor.opacity(0.45), mood.accentColor.opacity(0.05)],
                            center: .center,
                            startRadius: 8,
                            endRadius: 72
                        )
                    )
                    .frame(width: 140, height: 140)
                    .blur(radius: 4)
                    .scaleEffect(pulse && !reduceMotion ? 1.08 : 1.0)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulse)

                GlassCard(padding: 28, animate: false) {
                    Text(mood.emoji)
                        .font(.rf.largeTitle)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                        .accessibilityHidden(true)
                }
                .frame(width: 120, height: 120)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Current mood: \(mood.label), \(moodScore) of 5")

            Text(mood.label)
                .font(.rf.title)
                .foregroundStyle(Color.rfTextPrimary)
                .accessibilityHidden(true)

            scoreRow
        }
        .onAppear { if !reduceMotion { pulse = true } }
        .onChange(of: moodScore) { _, _ in
            onScoreChange?()
            ReflectMotion.perform(reduceMotion: reduceMotion) {
                pulse.toggle()
                pulse.toggle()
            }
        }
    }

    private var scoreRow: some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { score in
                let entry = MoodEntry(moodScore: score)
                let selected = moodScore == score
                Button {
                    ReflectMotion.perform(reduceMotion: reduceMotion) {
                        moodScore = score
                    }
                } label: {
                    VStack(spacing: 6) {
                        Text(entry.emoji)
                            .font(.rf.headline)
                            .opacity(selected ? 1 : 0.45)
                        Circle()
                            .fill(selected ? entry.accentColor : Color.rfAccentSubtle)
                            .frame(width: selected ? 10 : 6, height: selected ? 10 : 6)
                            .shadow(color: selected ? entry.accentColor.opacity(0.6) : .clear, radius: 8)
                    }
                    .frame(minWidth: 48, minHeight: 56)
                    .background(
                        selected
                            ? entry.accentColor.opacity(0.18)
                            : Color.clear,
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Mood \(score) of 5, \(entry.label)")
                .accessibilityHint(selected ? "Currently selected" : "Double tap to select")
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Mood scale")
    }
}
