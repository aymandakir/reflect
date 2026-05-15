import SwiftUI

/// Top narrative banner + skip control for guided check-in.
struct GuidedCheckInChrome: View {
    @Bindable var controller: GuidedCheckInController
    @AccessibilityFocusState.Binding var focus: GuidedA11yFocus?
    var onSkip: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Your first check-in")
                    .font(.rf.caption)
                    .foregroundStyle(Color.rfTextMuted)
                    .textCase(.uppercase)
                    .tracking(0.9)

                Text(controller.bannerMessage)
                    .font(.rf.headline)
                    .foregroundStyle(Color.rfTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(Color.rfCardBackground.opacity(0.7))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.rfGlassStroke, lineWidth: 1)
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Guided check-in. \(controller.bannerMessage)")
            .accessibilityFocused($focus, equals: .instruction)
            .padding(.horizontal, 20)
            .padding(.top, 8)

            HStack {
                Spacer()
                Button("Skip guided tour", action: onSkip)
                    .font(.rf.caption)
                    .foregroundStyle(Color.rfTextMuted)
                    .reflectMinimumTapTarget()
                    .accessibilityHint("Ends guided onboarding and opens standard check-in")
            }
            .padding(.horizontal, 24)
            .padding(.top, 6)
        }
        .transition(ReflectMotion.listItem(reduceMotion: reduceMotion))
        .animation(ReflectMotion.spring(reduceMotion: reduceMotion), value: controller.step)
        .accessibilitySortPriority(10)
    }
}

/// Dims inactive regions; active section stays interactive and receives focus glow.
struct GuidedSectionModifier: ViewModifier {
    let isActive: Bool
    let isGuided: Bool
    var moodScore: Int = 3
    var focus: AccessibilityFocusState<GuidedA11yFocus?>.Binding?
    var focusStep: GuidedA11yFocus?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(isGuided && !isActive ? 0.28 : 1)
            .allowsHitTesting(!isGuided || isActive)
            .accessibilityHidden(isGuided && !isActive)
            .accessibilityRespondsToUserInteraction(!isGuided || isActive)
            .overlay {
                if isGuided && isActive {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(
                            MoodEntry(moodScore: moodScore).accentColor.opacity(0.55),
                            lineWidth: 2
                        )
                        .shadow(
                            color: MoodEntry(moodScore: moodScore).accentColor.opacity(0.35),
                            radius: reduceMotion ? 0 : 14
                        )
                        .padding(-4)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .modifier(GuidedFocusModifier(focus: focus, focusStep: focusStep, isActive: isGuided && isActive))
            .animation(ReflectMotion.spring(reduceMotion: reduceMotion), value: isActive)
            .zIndex(isGuided && isActive ? 1 : 0)
    }
}

private struct GuidedFocusModifier: ViewModifier {
    var focus: AccessibilityFocusState<GuidedA11yFocus?>.Binding?
    var focusStep: GuidedA11yFocus?
    var isActive: Bool

    func body(content: Content) -> some View {
        if let focus, let focusStep, isActive {
            content.accessibilityFocused(focus, equals: focusStep)
        } else {
            content
        }
    }
}

extension View {
    func guidedSection(
        active step: GuidedCheckInController.GuidedCheckInStep,
        controller: GuidedCheckInController?,
        moodScore: Int,
        focus: AccessibilityFocusState<GuidedA11yFocus?>.Binding? = nil
    ) -> some View {
        let isGuided = controller != nil && controller?.step != .summary
        let isActive = controller?.step == step
        return modifier(GuidedSectionModifier(
            isActive: isActive,
            isGuided: isGuided,
            moodScore: moodScore,
            focus: focus,
            focusStep: step.a11yFocus
        ))
    }
}
