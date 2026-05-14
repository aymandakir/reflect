import SwiftUI

/// A frosted-glass card container inspired by Apple's "Liquid Glass" aesthetic.
///
/// Provides a translucent background with blur, a subtle white border,
/// and a soft shadow — adapts to both light and dark mode.
///
/// Usage:
///   GlassCard {
///       Text("Hello, world!")
///   }
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat
    var padding: CGFloat
    @ViewBuilder var content: () -> Content

    init(
        cornerRadius: CGFloat = 24,
        padding: CGFloat = 20,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .background(.ultraThinMaterial)
            .background(Color.rfSurface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.45),
                                .white.opacity(0.10),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
            .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Convenience Modifier

extension View {
    /// Wrap this view in a GlassCard.
    func glassCard(cornerRadius: CGFloat = 24, padding: CGFloat = 20) -> some View {
        GlassCard(cornerRadius: cornerRadius, padding: padding) {
            self
        }
    }
}

// MARK: - Preview

#Preview("GlassCard — Light") {
    ZStack {
        LinearGradient(
            colors: [Color.rfAccent.opacity(0.3), Color.rfBackground],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 16) {
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reflect").font(.rf.title)
                    Text("Your mood journal, beautifully simple.")
                        .font(.rf.body)
                        .foregroundStyle(Color.rfTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)

            Text("How are you feeling?")
                .glassCard(cornerRadius: 16, padding: 12)
        }
    }
}
