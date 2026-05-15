import SwiftUI

/// Layout variant for the shared aurora backdrop.
enum ReflectBackgroundVariant {
    /// Default — top-leading to bottom-trailing (Check-in, Journal).
    case standard
    /// Slightly different angle — feels like a “future dashboard” (Insights).
    case dashboard
}

/// Shared app atmosphere: aurora gradient + optional mood-reactive orbs.
struct ReflectBackground<Content: View>: View {
    var moodScore: Int = 3
    var subdued: Bool = false
    var variant: ReflectBackgroundVariant = .standard
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            auroraBase
            MoodSpaceOrbs(moodScore: moodScore, subdued: subdued)
            content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var auroraBase: some View {
        ZStack {
            AuroraGradient.linear(variant: variant)
            AuroraGradient.radialAccent(variant: variant)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

extension View {
    /// Layer this view over the Reflect aurora atmosphere with mood-reactive orbs.
    func reflectBackground(
        moodScore: Int = 3,
        subdued: Bool = false,
        variant: ReflectBackgroundVariant = .standard
    ) -> some View {
        ZStack {
            ReflectBackground(moodScore: moodScore, subdued: subdued, variant: variant) {
                Color.clear
            }
            self
        }
    }
}
