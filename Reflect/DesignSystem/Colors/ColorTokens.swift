import SwiftUI

// MARK: - Soft Aurora Glass Palette
//
// Semantic color tokens for Reflect. All UI should reference these names,
// not raw hex values. Light and dark variants are tuned for calm contrast
// (WCAG-friendly body text on background; accent text on rfTextOnAccent).

extension Color {
    // MARK: Surfaces

    /// Root canvas — neutral base behind the aurora gradient.
    static let rfBackground = Color(
        light: Color(hex: "F6F7FB"),
        dark: Color(hex: "12141F")
    )

    /// Secondary wash — cool blue tint in the aurora gradient.
    static let rfBackgroundSecondary = Color(
        light: Color(hex: "E4EDFA"),
        dark: Color(hex: "1A2238")
    )

    /// Soft lilac stop in the aurora gradient.
    static let rfBackgroundTertiary = Color(
        light: Color(hex: "EDE6F8"),
        dark: Color(hex: "221C32")
    )

    /// Glass card fill layered under material blur.
    static let rfCardBackground = Color(
        light: Color.white.opacity(0.62),
        dark: Color.white.opacity(0.09)
    )

    // MARK: Accent

    static let rfAccentPrimary = Color(
        light: Color(hex: "7C5CFC"),
        dark: Color(hex: "9B82FC")
    )

    static let rfAccentSubtle = Color(
        light: Color(hex: "7C5CFC").opacity(0.14),
        dark: Color(hex: "9B82FC").opacity(0.18)
    )

    // MARK: Text

    static let rfTextPrimary = Color(
        light: Color(hex: "1A1828"),
        dark: Color(hex: "F2F0F7")
    )

    /// Secondary copy — tuned for ≥4.5:1 on glass cards and aurora backgrounds.
    static let rfTextMuted = Color(
        light: Color(hex: "474452"),
        dark: Color(hex: "B8B5C4")
    )

    /// Text and icons on accent-filled controls.
    static let rfTextOnAccent = Color(
        light: Color.white,
        dark: Color.white
    )

    // MARK: Mood (data visualization & reactive tints)

    static let rfMoodLow  = Color(hex: "FF6B6B")
    static let rfMoodMid  = Color(hex: "FFD93D")
    static let rfMoodHigh = Color(hex: "6BCB77")

    // MARK: Glass chrome

    static let rfGlassStroke = Color.white.opacity(0.25)
    static let rfGlassShadow = Color.black.opacity(0.15)

    // MARK: Legacy aliases (prefer semantic names in new code)

    static var rfAccent: Color { rfAccentPrimary }
    static var rfAccentSoft: Color { rfAccentSubtle }
    static var rfTextSecondary: Color { rfTextMuted }
    static var rfSurface: Color { rfCardBackground }
}

// MARK: - Aurora backdrop

/// Calm multi-stop gradient for the app root (light blue → soft lilac).
enum AuroraGradient {
    static var stops: [Color] {
        [
            .rfBackgroundSecondary,
            .rfBackgroundTertiary,
            .rfBackground,
        ]
    }

    static var linear: LinearGradient {
        linear(variant: .standard)
    }

    static var radialAccent: RadialGradient {
        radialAccent(variant: .standard)
    }

    static func linear(variant: ReflectBackgroundVariant) -> LinearGradient {
        switch variant {
        case .standard:
            return LinearGradient(
                colors: stops,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dashboard:
            return LinearGradient(
                colors: stops.reversed(),
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
        }
    }

    static func radialAccent(variant: ReflectBackgroundVariant) -> RadialGradient {
        switch variant {
        case .standard:
            return RadialGradient(
                colors: [
                    Color.rfAccentSubtle.opacity(0.55),
                    Color.clear,
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 420
            )
        case .dashboard:
            return RadialGradient(
                colors: [
                    Color.rfAccentSubtle.opacity(0.42),
                    Color.clear,
                ],
                center: .bottomLeading,
                startRadius: 40,
                endRadius: 480
            )
        }
    }
}

// MARK: - Hex & adaptive helpers

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

    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
