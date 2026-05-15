import UIKit

/// Tactile feedback for Reflect interactions.
///
/// Usage:
///   Haptics.play(.selection)
///   Haptics.play(.success)
///
/// Respects `Haptics.isEnabled` (UserDefaults, default on).
enum Haptics {
    enum Style {
        case selection
        case light
        case success
        case warning
        case error
    }

    /// UserDefaults key shared with Settings (`@AppStorage`).
    static let userDefaultsKey = "reflectHapticsEnabled"

    private static let userEnabledKey = userDefaultsKey

    /// When `false`, `play` is a no-op. Defaults to `true`.
    static var isEnabled: Bool {
        get {
            guard UserDefaults.standard.object(forKey: userEnabledKey) != nil else { return true }
            return UserDefaults.standard.bool(forKey: userEnabledKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: userEnabledKey) }
    }

    private static let engines = Engines()

    private final class Engines {
        let selection = UISelectionFeedbackGenerator()
        let light = UIImpactFeedbackGenerator(style: .light)
        let notification = UINotificationFeedbackGenerator()

        func prepare(for style: Style) {
            switch style {
            case .selection:
                selection.prepare()
            case .light:
                light.prepare()
            case .success, .warning, .error:
                notification.prepare()
            }
        }
    }

    static func play(_ style: Style) {
        guard isEnabled else { return }
        engines.prepare(for: style)

        switch style {
        case .selection:
            engines.selection.selectionChanged()
        case .light:
            engines.light.impactOccurred()
        case .success:
            engines.notification.notificationOccurred(.success)
        case .warning:
            engines.notification.notificationOccurred(.warning)
        case .error:
            engines.notification.notificationOccurred(.error)
        }
    }
}
