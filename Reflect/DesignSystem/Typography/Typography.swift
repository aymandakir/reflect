import SwiftUI

/// Typographic scale that respects Dynamic Type.
///
/// Every token maps to a semantic `Font.TextStyle`, which means the system
/// automatically scales text for the user's preferred content size.
/// The `.rounded` design gives Reflect its signature friendly feel.
///
/// Usage:
///   Text("Title").font(.rf.title)
///   Text("Body").font(.rf.body)
extension Font {
    enum rf {
        static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
        static let title      = Font.system(.title,      design: .rounded, weight: .bold)
        static let title2     = Font.system(.title2,     design: .rounded, weight: .semibold)
        static let title3     = Font.system(.title3,     design: .rounded, weight: .semibold)
        static let headline   = Font.system(.headline,   design: .rounded, weight: .semibold)
        static let body       = Font.system(.body,       design: .default, weight: .regular)
        static let callout    = Font.system(.callout,    design: .default, weight: .regular)
        static let subhead    = Font.system(.subheadline,design: .default, weight: .regular)
        static let footnote   = Font.system(.footnote,   design: .default, weight: .regular)
        static let caption    = Font.system(.caption,    design: .rounded, weight: .medium)
        static let caption2   = Font.system(.caption2,   design: .rounded, weight: .regular)
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
