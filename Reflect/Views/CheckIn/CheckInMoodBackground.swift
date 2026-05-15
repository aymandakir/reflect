import SwiftUI

/// Aurora backdrop with a mood-reactive color wash (cooler when low, warmer when high).
struct CheckInMoodBackground: View {
    let moodScore: Int

    var body: some View {
        ZStack {
            ReflectBackground(moodScore: moodScore, subdued: false) {
                Color.clear
            }

            moodWash
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.28), value: moodScore)
        }
        .accessibilityHidden(true)
    }

    private var moodWash: LinearGradient {
        let accent = MoodEntry(moodScore: moodScore).accentColor
        let intensity: Double = switch moodScore {
        case 1: 0.22
        case 2: 0.16
        case 3: 0.08
        case 4: 0.14
        case 5: 0.20
        default: 0.08
        }
        return LinearGradient(
            colors: [
                accent.opacity(intensity),
                Color.clear,
                accent.opacity(intensity * 0.5),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
