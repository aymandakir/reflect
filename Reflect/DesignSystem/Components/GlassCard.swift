import SwiftUI

/// Visual weight for glass cards.
enum GlassCardStyle {
    case standard
    case elevated
}

/// Single source of truth for Soft Aurora Glass cards.
struct GlassCard<Content: View>: View {
    var style: GlassCardStyle
    var padding: CGFloat
    var animate: Bool
    var moodTint: Int?
    @ViewBuilder var content: () -> Content

    private let cornerRadius: CGFloat = 24

    init(
        style: GlassCardStyle = .standard,
        padding: CGFloat = 20,
        animate: Bool = true,
        moodTint: Int? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.style = style
        self.padding = padding
        self.animate = animate
        self.moodTint = moodTint
        self.content = content
    }

    private var tintColor: Color? {
        guard let moodTint else { return nil }
        return MoodEntry(moodScore: moodTint).accentColor
    }

    private var shadowRadius: CGFloat { style == .elevated ? 28 : 20 }
    private var shadowY: CGFloat { style == .elevated ? 14 : 10 }

    var body: some View {
        content()
            .padding(padding)
            .background { cardBackground }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.rfGlassStroke, lineWidth: 1)
            )
            .shadow(color: Color.rfGlassShadow, radius: shadowRadius, x: 0, y: shadowY)
            .reflectCardAppear(enabled: animate, heroLift: style == .elevated)
            .animation(.easeInOut(duration: ReflectMotion.Duration.standard), value: moodTint)
    }

    @ViewBuilder
    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.rfCardBackground)
            if let tintColor {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tintColor.opacity(0.12), tintColor.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
    }
}

extension View {
    func glassCard(
        style: GlassCardStyle = .standard,
        padding: CGFloat = 20,
        moodTint: Int? = nil
    ) -> some View {
        GlassCard(style: style, padding: padding, moodTint: moodTint) {
            self
        }
    }
}
