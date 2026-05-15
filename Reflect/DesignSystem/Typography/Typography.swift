import SwiftUI

/// Soft Aurora Glass typographic scale — Dynamic Type via semantic text styles.
///
/// Usage:
///   Text("Reflect").font(.rf.largeTitle)
///   Text("3.8").font(.rf.number)
extension Font {
    enum rf {
        static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
        static let title      = Font.system(.title, design: .rounded, weight: .bold)
        static let headline   = Font.system(.headline, design: .rounded, weight: .semibold)
        static let body       = Font.system(.body, design: .default, weight: .regular)
        static let caption    = Font.system(.caption, design: .rounded, weight: .medium)

        /// Mood scores, stats, and numeric insights.
        static let number = Font.system(.title, design: .rounded, weight: .bold)
            .monospacedDigit()

        /// Large decorative emoji (mood hero, summary).
        static let emoji = Font.system(.largeTitle, design: .rounded)

        /// Row / list emoji (journal entries).
        static let emojiRow = Font.system(.title2, design: .rounded)

        /// SF Symbol icons in empty states.
        static let symbol = Font.system(.title, design: .rounded)

        // MARK: Aliases (migrate screens gradually)

        static let title2   = title
        static let title3   = headline
        static let subhead  = body
        static let callout  = body
        static let footnote = caption
        static let caption2 = caption
    }
}

// MARK: - Text style modifiers

extension View {
    func rfLargeTitle() -> some View {
        font(.rf.largeTitle).foregroundStyle(Color.rfTextPrimary)
    }

    func rfTitle() -> some View {
        font(.rf.title).foregroundStyle(Color.rfTextPrimary)
    }

    func rfHeadline() -> some View {
        font(.rf.headline).foregroundStyle(Color.rfTextPrimary)
    }

    func rfBody() -> some View {
        font(.rf.body).foregroundStyle(Color.rfTextPrimary)
    }

    func rfCaption() -> some View {
        font(.rf.caption).foregroundStyle(Color.rfTextMuted)
    }

    func rfNumber() -> some View {
        font(.rf.number).foregroundStyle(Color.rfTextPrimary)
    }
}
