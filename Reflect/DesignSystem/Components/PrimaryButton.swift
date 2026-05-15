import SwiftUI

/// Primary call-to-action for Reflect — accent fill, on-accent text, soft glow.
struct PrimaryButton: View {
    let title: String
    var moodScore: Int? = nil
    var isEnabled: Bool = true
    let action: () -> Void

    private var tint: Color {
        if let moodScore { return MoodEntry(moodScore: moodScore).accentColor }
        return .rfAccentPrimary
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.rf.headline)
                .foregroundStyle(Color.rfTextOnAccent)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(minHeight: ReflectAccessibility.minTapDimension)
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .background {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [tint, tint.opacity(0.82)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.28), lineWidth: 1)
                        )
                        .shadow(color: tint.opacity(0.4), radius: 14, y: 6)
                }
        }
        .reflectPressButtonStyle()
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
        .accessibilityLabel(title)
        .accessibilityHint(isEnabled ? "Double tap to activate" : "Unavailable")
        .accessibilityAddTraits(.isButton)
    }
}

/// Backward-compatible alias.
typealias PrimaryGlassButton = PrimaryButton
