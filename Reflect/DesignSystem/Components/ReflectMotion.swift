import SwiftUI

// MARK: - Timing & animation tokens

/// Central motion vocabulary for Reflect — durations, springs, and transitions.
enum ReflectMotion {
    enum Duration {
        static let press: Double = 0.22
        static let standard: Double = 0.32
        static let entrance: Double = 0.45
        static let chartReveal: Double = 0.9
    }

    enum Offset {
        static let cardAppear: CGFloat = 14
        static let listInsert: CGFloat = 12
    }

    enum Scale {
        static let press: CGFloat = 0.97
        static let emojiPulse: CGFloat = 1.14
        static let cardHidden: CGFloat = 0.97
    }

    // MARK: - Animation factories

    static func spring(reduceMotion: Bool) -> Animation? {
        reduceMotion
            ? .easeInOut(duration: Duration.press)
            : .spring(response: 0.38, dampingFraction: 0.72)
    }

    static func press(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.65)
    }

    static func entrance(reduceMotion: Bool, delay: Double = 0) -> Animation? {
        if reduceMotion {
            let base = Animation.easeInOut(duration: Duration.press)
            return delay > 0 ? base.delay(delay) : base
        }
        return .spring(response: 0.48, dampingFraction: 0.82).delay(delay)
    }

    static func list(reduceMotion: Bool) -> Animation? {
        reduceMotion
            ? .easeInOut(duration: Duration.standard)
            : .spring(response: 0.4, dampingFraction: 0.85)
    }

    static func chartReveal(reduceMotion: Bool, delay: Double = 0.2) -> Animation? {
        reduceMotion
            ? .easeInOut(duration: Duration.press)
            : .easeOut(duration: Duration.chartReveal).delay(delay)
    }

    // MARK: - Transitions

    static func listItem(reduceMotion: Bool) -> AnyTransition {
        if reduceMotion { return .opacity }
        return .asymmetric(
            insertion: .opacity.combined(with: .offset(y: Offset.listInsert)),
            removal: .opacity.combined(with: .offset(x: -20))
        )
    }

    static func overlay(reduceMotion: Bool) -> AnyTransition {
        if reduceMotion { return .opacity }
        return .opacity.combined(with: .scale(scale: 0.98))
    }

    // MARK: - Imperative helper

    static func perform(
        reduceMotion: Bool,
        animation: Animation? = nil,
        _ updates: () -> Void
    ) {
        let resolved = animation ?? spring(reduceMotion: reduceMotion)
        if let resolved {
            withAnimation(resolved, updates)
        } else {
            updates()
        }
    }
}

// MARK: - Button press

/// Subtle scale feedback on primary controls.
struct ReflectPressButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(
                configuration.isPressed && !reduceMotion
                    ? ReflectMotion.Scale.press
                    : 1
            )
            .animation(
                ReflectMotion.press(reduceMotion: reduceMotion),
                value: configuration.isPressed
            )
    }
}

// MARK: - Glass card entrance

private struct ReflectCardAppearModifier: ViewModifier {
    let enabled: Bool
  let heroLift: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(enabled ? (appeared ? 1 : 0) : 1)
            .offset(y: enabled && heroLift && !reduceMotion ? (appeared ? 0 : ReflectMotion.Offset.cardAppear) : 0)
            .scaleEffect(enabled && !reduceMotion ? (appeared ? 1 : ReflectMotion.Scale.cardHidden) : 1)
            .onAppear {
                guard enabled, !appeared else { return }
                if reduceMotion {
                    appeared = true
                } else {
                    withAnimation(ReflectMotion.entrance(reduceMotion: false)) {
                        appeared = true
                    }
                }
            }
    }
}

// MARK: - Mood emoji pulse

private struct ReflectMoodEmojiModifier: ViewModifier {
    let moodScore: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1 : (pulsing ? ReflectMotion.Scale.emojiPulse : 1))
            .opacity(reduceMotion ? 1 : (pulsing ? 0.82 : 1))
            .onChange(of: moodScore) { _, _ in
                triggerPulse()
            }
    }

    private func triggerPulse() {
        guard !reduceMotion else { return }
        ReflectMotion.perform(reduceMotion: false) {
            pulsing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + ReflectMotion.Duration.press) {
            ReflectMotion.perform(reduceMotion: false) {
                pulsing = false
            }
        }
    }
}

// MARK: - View extensions

extension View {
    /// Fade + optional upward lift for glass cards on first appear.
    func reflectCardAppear(enabled: Bool = true, heroLift: Bool = false) -> some View {
        modifier(ReflectCardAppearModifier(enabled: enabled, heroLift: heroLift))
    }

    /// Spring scale + opacity when mood score changes (hero emoji).
    func reflectMoodEmojiPulse(moodScore: Int) -> some View {
        modifier(ReflectMoodEmojiModifier(moodScore: moodScore))
    }

    /// List insert / remove transition respecting Reduce Motion.
    func reflectListItemTransition(reduceMotion: Bool) -> some View {
        transition(ReflectMotion.listItem(reduceMotion: reduceMotion))
    }

    func reflectPressButtonStyle() -> some View {
        buttonStyle(ReflectPressButtonStyle())
    }
}
