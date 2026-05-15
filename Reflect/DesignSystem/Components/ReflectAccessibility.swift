import SwiftUI

// MARK: - Guided VoiceOver focus

/// VoiceOver focus targets for the guided first check-in.
enum GuidedA11yFocus: Hashable {
    case instruction
    case mood
    case tags
    case note
}

extension GuidedCheckInController.GuidedCheckInStep {
    var a11yFocus: GuidedA11yFocus? {
        switch self {
        case .mood: return .mood
        case .tags: return .tags
        case .note: return .note
        case .summary: return nil
        }
    }
}

// MARK: - Layout helpers

enum ReflectAccessibility {
    /// Minimum recommended touch target (Apple HIG).
    static let minTapDimension: CGFloat = 44

    static func isAccessibilitySize(_ size: DynamicTypeSize) -> Bool {
        size.isAccessibilitySize
    }
}

// MARK: - View modifiers

extension View {
    /// Ensures at least a 44×44 pt hit area while preserving visual size.
    func reflectMinimumTapTarget(
        alignment: Alignment = .center
    ) -> some View {
        frame(
            minWidth: ReflectAccessibility.minTapDimension,
            minHeight: ReflectAccessibility.minTapDimension,
            alignment: alignment
        )
        .contentShape(Rectangle())
    }

    /// Capsule / chip controls: expand touch area without changing label layout.
    func reflectChipTapTarget() -> some View {
        padding(.vertical, 6)
            .padding(.horizontal, 2)
            .frame(minHeight: ReflectAccessibility.minTapDimension)
            .contentShape(Capsule())
    }
}
