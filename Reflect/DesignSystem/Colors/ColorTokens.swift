import SwiftUI

/// Centralized color palette that adapts to light & dark mode.
///
/// Usage:
///   Text("Hello").foregroundStyle(Color.Theme.textPrimary)
///   view.background(Color.Theme.surfaceGlass)
enum Theme {
    // MARK: - Backgrounds

    /// Main canvas behind all content.
    static let backgroundPrimary = Color("backgroundPrimary", bundle: nil)
    /// Card / elevated surface background — semi-transparent for glass effect.
    static let surfaceGlass = Color("surfaceGlass", bundle: nil)

    // MARK: - Text

    static let textPrimary   = Color("textPrimary", bundle: nil)
    static let textSecondary = Color("textSecondary", bundle: nil)

    // MARK: - Accent

    static let accent        = Color("accentColor", bundle: nil)
    static let accentSoft    = Color("accentSoft", bundle: nil)

    // MARK: - Mood gradient stops

    static let moodLow       = Color("moodLow", bundle: nil)
    static let moodMid       = Color("moodMid", bundle: nil)
    static let moodHigh      = Color("moodHigh", bundle: nil)

    // MARK: - Glass border

    static let glassBorder   = Color.white.opacity(0.25)
    static let glassShadow   = Color.black.opacity(0.08)
}

// MARK: - Adaptive Fallbacks

/// Programmatic fallback colors when asset catalog colors are unavailable.
/// These are used as the canonical palette during development.
extension Color {
    // Light / Dark adaptive colors built from code.
    static let rfBackground      = Color(light: .init(hex: "F2F0F7"), dark: .init(hex: "1C1B2E"))
    static let rfSurface         = Color(light: .white.opacity(0.55), dark: .white.opacity(0.08))
    static let rfTextPrimary     = Color(light: .init(hex: "1C1B2E"), dark: .init(hex: "F2F0F7"))
    static let rfTextSecondary   = Color(light: .init(hex: "6E6B7B"), dark: .init(hex: "A09DAE"))
    static let rfAccent          = Color(light: .init(hex: "7C5CFC"), dark: .init(hex: "9B82FC"))
    static let rfAccentSoft      = Color(light: .init(hex: "7C5CFC").opacity(0.12), dark: .init(hex: "9B82FC").opacity(0.15))
    static let rfMoodLow         = Color(hex: "FF6B6B")
    static let rfMoodMid         = Color(hex: "FFD93D")
    static let rfMoodHigh        = Color(hex: "6BCB77")
}

// MARK: - Hex Initializer

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: .alphanumerics.inverted))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red:   Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8)  & 0xFF) / 255,
            blue:  Double(rgb & 0xFF) / 255
        )
    }

    /// Create an adaptive color from explicit light and dark variants.
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}
