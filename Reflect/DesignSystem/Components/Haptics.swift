import UIKit

/// Thin wrapper around UIKit haptic feedback generators.
///
/// Usage:
///   Haptics.play(.selection)
///   Haptics.play(.success)
enum Haptics {
    enum Style {
        case selection
        case light
        case success
        case warning
        case error
    }

    static func play(_ style: Style) {
        switch style {
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
