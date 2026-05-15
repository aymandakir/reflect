import SwiftUI

/// Hero mood capsule — title, animated emoji, label, and five score buttons.
struct MoodCapsuleView: View {
    @Binding var moodScore: Int
    var onScoreChange: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var mood: MoodEntry { MoodEntry(moodScore: moodScore) }

    private var usesWrappedScoreRow: Bool {
        ReflectAccessibility.isAccessibilitySize(dynamicTypeSize)
    }

    var body: some View {
        VStack(spacing: 22) {
            Text("How are you feeling?")
                .font(.rf.headline)
                .foregroundStyle(Color.rfTextPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(mood.emoji)
                .font(.rf.emoji)
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                .reflectMoodEmojiPulse(moodScore: moodScore)
                .accessibilityHidden(true)

            Text(mood.label)
                .font(.rf.title)
                .foregroundStyle(mood.accentColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .contentTransition(.numericText())
                .animation(ReflectMotion.spring(reduceMotion: reduceMotion), value: moodScore)
                .accessibilityHidden(true)

            moodScoreRow
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("How are you feeling? Mood \(moodScore) of 5, \(mood.label)")
        .onChange(of: moodScore) { _, _ in
            onScoreChange?()
        }
    }

    @ViewBuilder
    private var moodScoreRow: some View {
        if usesWrappedScoreRow {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: ReflectAccessibility.minTapDimension), spacing: 8)],
                spacing: 8
            ) {
                ForEach(1...5, id: \.self) { score in
                    moodScoreButton(score: score)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Mood scale, 1 through 5")
        } else {
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { score in
                    moodScoreButton(score: score)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Mood scale, 1 through 5")
        }
    }

    private func moodScoreButton(score: Int) -> some View {
        let entry = MoodEntry(moodScore: score)
        let selected = moodScore == score
        return Button {
            ReflectMotion.perform(reduceMotion: reduceMotion) {
                moodScore = score
            }
        } label: {
            Text("\(score)")
                .font(.rf.headline)
                .frame(
                    minWidth: ReflectAccessibility.minTapDimension,
                    minHeight: ReflectAccessibility.minTapDimension
                )
                .background {
                    Circle()
                        .fill(selected ? entry.accentColor : Color.rfCardBackground.opacity(0.6))
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    selected ? entry.accentColor : Color.rfGlassStroke,
                                    lineWidth: selected ? 2 : 1
                                )
                        )
                        .shadow(
                            color: selected ? entry.accentColor.opacity(0.45) : .clear,
                            radius: 10
                        )
                }
                .foregroundStyle(selected ? Color.rfTextOnAccent : Color.rfTextPrimary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Mood \(score) of 5, \(entry.label)")
        .accessibilityHint(selected ? "Currently selected" : "Double tap to select")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
