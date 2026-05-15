import Foundation
import SwiftUI

/// Tracks the guided first check-in narrative layered on top of CheckInView.
@Observable
final class GuidedCheckInController {
    var step: GuidedCheckInStep = .mood
    var savedEntry: MoodEntry?

    enum GuidedCheckInStep: Int, CaseIterable {
        case mood
        case tags
        case note
        case summary

        var focusStepIndex: Int? {
            switch self {
            case .mood: return 1
            case .tags: return 2
            case .note: return 3
            case .summary: return nil
            }
        }

        static let guidedPhaseCount = 3
    }

    // MARK: - Copy

    var bannerMessage: String {
        switch step {
        case .mood:
            return "Step 1 of 3 – Choose how you feel right now. Trust your first instinct."
        case .tags:
            return "Step 2 of 3 – Tag what's influencing your mood (work, friends, health…)."
        case .note:
            return "Step 3 of 3 – Add a sentence, or leave it blank. It's your space."
        case .summary:
            return ""
        }
    }

    var accessibilityStepAnnouncement: String {
        switch step {
        case .mood: return "Step 1 of 3. Choose your mood."
        case .tags: return "Step 2 of 3. Add tags."
        case .note: return "Step 3 of 3. Add an optional note."
        case .summary: return "Check-in complete. Summary."
        }
    }

    static func reassurance(for moodScore: Int) -> String {
        switch moodScore {
        case 1, 2:
            return "Acknowledging hard moments takes courage. You're allowed to feel exactly as you do."
        case 3:
            return "Every day has layers. Noticing yours is a quiet, powerful act of care."
        case 4, 5:
            return "There's light in today. This moment is worth remembering."
        default:
            return "Thank you for showing up for yourself today."
        }
    }

    // MARK: - Navigation

    func advanceToTags(reduceMotion: Bool) {
        transition(to: .tags, reduceMotion: reduceMotion)
    }

    func advanceToNote(reduceMotion: Bool) {
        transition(to: .note, reduceMotion: reduceMotion)
    }

    func showSummary(entry: MoodEntry, reduceMotion: Bool) {
        savedEntry = entry
        transition(to: .summary, reduceMotion: reduceMotion)
    }

    private func transition(to newStep: GuidedCheckInStep, reduceMotion: Bool) {
        ReflectMotion.perform(reduceMotion: reduceMotion) {
            step = newStep
        }
        AccessibilityNotification.Announcement(accessibilityStepAnnouncement).post()
    }
}
