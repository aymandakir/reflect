import SwiftUI

/// Typographic scale for consistent text styling across the app.
///
/// Usage:
///   Text("Title").font(.rf.title)
///   Text("Body").font(.rf.body)
extension Font {
    enum rf {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title      = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2     = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let title3     = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline   = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body       = Font.system(size: 17, weight: .regular, design: .default)
        static let callout    = Font.system(size: 16, weight: .regular, design: .default)
        static let subhead    = Font.system(size: 15, weight: .regular, design: .default)
        static let footnote   = Font.system(size: 13, weight: .regular, design: .default)
        static let caption    = Font.system(size: 12, weight: .medium, design: .rounded)
        static let caption2   = Font.system(size: 11, weight: .regular, design: .rounded)

        /// Mood score display — large rounded numeral.
        static let moodDisplay = Font.system(size: 64, weight: .heavy, design: .rounded)
    }
}

// MARK: - View Modifiers

extension View {
    func rfTitle() -> some View {
        self.font(.rf.title)
            .foregroundStyle(Color.rfTextPrimary)
    }

    func rfBody() -> some View {
        self.font(.rf.body)
            .foregroundStyle(Color.rfTextPrimary)
    }

    func rfCaption() -> some View {
        self.font(.rf.caption)
            .foregroundStyle(Color.rfTextSecondary)
    }
}
