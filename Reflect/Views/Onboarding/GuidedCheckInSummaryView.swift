import SwiftUI

/// Full-screen summary after the guided first check-in.
struct GuidedCheckInSummaryView: View {
    let entry: MoodEntry
    var onSeeJournal: () -> Void
    var onSeeInsights: () -> Void

    var body: some View {
        ZStack {
            CheckInMoodBackground(moodScore: entry.moodScore)

            ScrollView {
                VStack(spacing: 28) {
                    Spacer(minLength: 40)

                    GlassCard(style: .elevated, padding: 32, moodTint: entry.moodScore) {
                        VStack(spacing: 20) {
                            Text(entry.emoji)
                                .font(.rf.emoji)
                                .accessibilityHidden(true)

                            Text(entry.label)
                                .font(.rf.title)
                                .foregroundStyle(Color.rfTextPrimary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)

                            if !entry.tags.isEmpty {
                                Text(entry.tags.joined(separator: " · "))
                                    .font(.rf.caption)
                                    .foregroundStyle(Color.rfTextMuted)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            if let note = entry.note, !note.isEmpty {
                                Text(note)
                                    .font(.rf.body)
                                    .foregroundStyle(Color.rfTextMuted)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Divider().opacity(0.35)

                            Text(GuidedCheckInController.reassurance(for: entry.moodScore))
                                .font(.rf.body)
                                .foregroundStyle(Color.rfTextPrimary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 24)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(summaryAccessibilityLabel)
                    .accessibilityAddTraits(.isHeader)

                    VStack(spacing: 12) {
                        PrimaryButton(title: "See your journal", moodScore: entry.moodScore, action: onSeeJournal)
                            .accessibilityHint("Opens your journal with this check-in")

                        Button(action: onSeeInsights) {
                            Text("See how your story will look")
                                .font(.rf.headline)
                                .foregroundStyle(Color.rfAccentPrimary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: ReflectAccessibility.minTapDimension)
                                .padding(.vertical, 8)
                        }
                        .reflectPressButtonStyle()
                        .accessibilityLabel("See how your story will look")
                        .accessibilityHint("Opens insights with a preview of your trends")
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 48)
                }
            }
        }
        .ignoresSafeArea()
        .accessibilityElement(children: .contain)
        .onAppear {
            AccessibilityNotification.Announcement(
                "First check-in saved. \(entry.label). \(GuidedCheckInController.reassurance(for: entry.moodScore))"
            ).post()
        }
    }

    private var summaryAccessibilityLabel: String {
        var parts = ["First check-in complete", entry.label, "mood \(entry.moodScore) of 5"]
        if !entry.tags.isEmpty {
            parts.append("tags: \(entry.tags.joined(separator: ", "))")
        }
        if let note = entry.note, !note.isEmpty {
            parts.append(note)
        }
        parts.append(GuidedCheckInController.reassurance(for: entry.moodScore))
        return parts.joined(separator: ". ")
    }
}

#if DEBUG
#Preview("Onboarding – Summary card") {
    GuidedCheckInSummaryView(
        entry: DesignPreviewProvider.sampleFirstCheckInEntry(),
        onSeeJournal: {},
        onSeeInsights: {}
    )
}
#endif
