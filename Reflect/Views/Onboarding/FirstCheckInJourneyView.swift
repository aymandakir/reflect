import SwiftUI

/// Guided first check-in — a living mood space, not a carousel.
/// Walks the user through arrival → mood → tags → note → seal (save).
struct FirstCheckInJourneyView: View {
    var store: MoodStore
    var onFinish: () -> Void

    @State private var step: JourneyStep = .arrival
    @State private var moodScore = 3
    @State private var selectedTags: Set<String> = []
    @State private var note = ""
    @State private var breathePhase = false
    @State private var sealed = false

    private let journeyTags = ["calm", "grateful", "tired", "hopeful", "stressed", "energized"]

    enum JourneyStep: Int, CaseIterable {
        case arrival, mood, tags, note, seal

        var title: String {
            switch self {
            case .arrival: return "Arrive"
            case .mood: return "Feel"
            case .tags: return "Context"
            case .note: return "Reflect"
            case .seal: return "Seal"
            }
        }
    }

    var body: some View {
        ReflectBackground(moodScore: moodScore, subdued: step == .arrival) {
            VStack(spacing: 0) {
                journeyPath
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                Group {
                    switch step {
                    case .arrival: arrivalStep
                    case .mood: moodStep
                    case .tags: tagsStep
                    case .note: noteStep
                    case .seal: sealStep
                    }
                }
                .frame(maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .offset(y: 24)),
                    removal: .opacity.combined(with: .offset(y: -16))
                ))
            }
        }
        .animation(.easeInOut(duration: 0.55), value: step)
        .animation(.easeInOut(duration: 0.8), value: moodScore)
    }

    // MARK: - Path Indicator

    private var journeyPath: some View {
        HStack(spacing: 0) {
            ForEach(JourneyStep.allCases, id: \.self) { s in
                let active = s.rawValue <= step.rawValue
                Capsule()
                    .fill(active ? MoodEntry(moodScore: moodScore).accentColor : Color.rfAccentSubtle)
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Journey progress, step \(step.rawValue + 1) of \(JourneyStep.allCases.count), \(step.title)")
    }

    // MARK: - Steps

    private var arrivalStep: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Text("Reflect")
                    .font(.rf.largeTitle)
                    .foregroundStyle(Color.rfTextPrimary)

                Text("Step into your mood space")
                    .font(.rf.headline)
                    .foregroundStyle(Color.rfTextMuted)
                    .multilineTextAlignment(.center)

                Text("Take a slow breath. This is a quiet place to notice how you feel — no accounts, no noise, just you.")
                    .font(.rf.body)
                    .foregroundStyle(Color.rfTextMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
                    .opacity(breathePhase ? 1 : 0.72)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: breathePhase)
            }
            .padding(.horizontal, 28)

            Spacer()

            PrimaryGlassButton(title: "Enter your space") {
                Haptics.play(.light)
                advance(to: .mood)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .onAppear { breathePhase = true }
    }

    private var moodStep: some View {
        VStack(spacing: 20) {
            stepHeader(
                title: "How does it feel right now?",
                subtitle: "There is no wrong answer. Choose what is true in this moment."
            )

            GlassCard(style: .elevated, moodTint: moodScore) {
                MoodOrbSelector(moodScore: $moodScore) {
                    Haptics.play(.selection)
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            HStack(spacing: 12) {
                secondaryButton("Back") { retreat(to: .arrival) }
                PrimaryGlassButton(title: "Continue", moodScore: moodScore) {
                    advance(to: .tags)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    private var tagsStep: some View {
        VStack(spacing: 20) {
            stepHeader(
                title: "What is present with you?",
                subtitle: "Optional — tap anything that resonates, or skip ahead."
            )

            GlassCard(moodTint: moodScore) {
                FlowLayout(spacing: 10) {
                    ForEach(journeyTags, id: \.self) { tag in
                        TagChip(label: tag, isSelected: selectedTags.contains(tag)) {
                            Haptics.play(.light)
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)

            Spacer()

            HStack(spacing: 12) {
                secondaryButton("Back") { retreat(to: .mood) }
                PrimaryGlassButton(title: selectedTags.isEmpty ? "Skip" : "Continue", moodScore: moodScore) {
                    advance(to: .note)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    private var noteStep: some View {
        VStack(spacing: 20) {
            stepHeader(
                title: "A few words, if you like",
                subtitle: "Leave a whisper for future-you — or leave it blank."
            )

            GlassCard(moodTint: moodScore) {
                TextField("What's alive in you right now?", text: $note, axis: .vertical)
                    .lineLimit(3...6)
                    .font(.rf.body)
                    .textFieldStyle(.plain)
                    .accessibilityLabel("Journal note")
            }
            .padding(.horizontal, 20)

            Spacer()

            HStack(spacing: 12) {
                secondaryButton("Back") { retreat(to: .tags) }
                PrimaryGlassButton(title: note.isEmpty ? "Skip" : "Continue", moodScore: moodScore) {
                    advance(to: .seal)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    private var sealStep: some View {
        let preview = MoodEntry(moodScore: moodScore, tags: Array(selectedTags), note: note.isEmpty ? nil : note)

        return VStack(spacing: 24) {
            stepHeader(
                title: "Seal this moment",
                subtitle: "Your first entry will live privately on this device."
            )

            GlassCard(style: .elevated, moodTint: moodScore) {
                VStack(spacing: 16) {
                    Text(preview.emoji)
                        .font(.system(.largeTitle, design: .rounded))
                        .accessibilityHidden(true)

                    Text(preview.label)
                        .font(.rf.title)
                        .foregroundStyle(Color.rfTextPrimary)

                    if !preview.tags.isEmpty {
                        Text(preview.tags.joined(separator: " · "))
                            .font(.rf.caption)
                            .foregroundStyle(Color.rfTextMuted)
                    }

                    if let n = preview.note, !n.isEmpty {
                        Text(n)
                            .font(.rf.body)
                            .foregroundStyle(Color.rfTextMuted)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .scaleEffect(sealed ? 1.02 : 1)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: sealed)

            Spacer()

            PrimaryGlassButton(title: sealed ? "Opening your space…" : "Seal & begin", moodScore: moodScore, isEnabled: !sealed) {
                sealEntry(preview)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Helpers

    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.rf.title)
                .foregroundStyle(Color.rfTextPrimary)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.rf.body)
                .foregroundStyle(Color.rfTextMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .accessibilityElement(children: .combine)
    }

    private func secondaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.rf.headline)
                .foregroundStyle(Color.rfTextPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func advance(to next: JourneyStep) {
        withAnimation { step = next }
    }

    private func retreat(to previous: JourneyStep) {
        withAnimation { step = previous }
    }

    private func sealEntry(_ entry: MoodEntry) {
        sealed = true
        Haptics.play(.success)
        store.add(entry)
        AccessibilityNotification.Announcement("First mood entry saved. Welcome to Reflect.").post()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            onFinish()
        }
    }
}

// MARK: - Preview

#Preview {
    FirstCheckInJourneyView(store: MoodStore(), onFinish: {})
}
