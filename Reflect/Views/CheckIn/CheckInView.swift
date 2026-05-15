import SwiftUI

/// Cinematic check-in — one floating mood capsule over an aurora field.
/// Supports an optional guided first check-in narrative overlay.
struct CheckInView: View {
    @Bindable var vm: CheckInViewModel
    var guided: GuidedCheckInController?
    var onGuidedSkip: (() -> Void)?
    var onGuidedFinish: ((ContentView.Tab) -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AccessibilityFocusState private var guidedA11yFocus: GuidedA11yFocus?
    @FocusState private var noteFocused: Bool
    @State private var lastSealedMoodScore = 3
    @State private var showsSettings = false

    private var isGuided: Bool { guided != nil }
    private var guidedStep: GuidedCheckInController.GuidedCheckInStep? { guided?.step }

    var body: some View {
        NavigationStack {
            ZStack {
                CheckInMoodBackground(moodScore: vm.moodScore)
                    .animation(ReflectMotion.spring(reduceMotion: reduceMotion), value: guidedStep)

                ScrollView {
                    VStack(spacing: 16) {
                        if isGuided, guidedStep != .summary {
                            Color.clear.frame(height: 88)
                        }
                        moodCapsule
                        tagsCard
                        noteArea
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                }
                .scrollDismissesKeyboard(.interactively)

                if isGuided, guidedStep == .summary, let entry = guided?.savedEntry {
                    GuidedCheckInSummaryView(
                        entry: entry,
                        onSeeJournal: { onGuidedFinish?(.journal) },
                        onSeeInsights: { onGuidedFinish?(.insights) }
                    )
                    .transition(ReflectMotion.overlay(reduceMotion: reduceMotion))
                }
            }
            .overlay(alignment: .top) {
                if isGuided, guidedStep != .summary, let guided {
                    GuidedCheckInChrome(
                        controller: guided,
                        focus: $guidedA11yFocus,
                        onSkip: { onGuidedSkip?() }
                    )
                }
            }
            .navigationTitle(isGuided ? "Welcome" : "Check In")
            .onAppear {
                if isGuided, let step = guidedStep {
                    scheduleGuidedFocus(for: step)
                }
            }
            .onChange(of: guided?.step) { _, newStep in
                guard let newStep else { return }
                scheduleGuidedFocus(for: newStep)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsToolbarButton
                }
            }
            .sheet(isPresented: $showsSettings) {
                SettingsView()
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if guidedStep != .summary {
                    bottomBar
                }
            }
            .overlay {
                if !isGuided {
                    confirmationOverlay
                }
            }
        }
    }

    // MARK: - Settings

    private var settingsToolbarButton: some View {
        Button {
            showsSettings = true
        } label: {
            Image(systemName: "gearshape")
                .font(.rf.body)
                .foregroundStyle(Color.rfTextPrimary)
                .frame(
                    width: ReflectAccessibility.minTapDimension,
                    height: ReflectAccessibility.minTapDimension
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Settings")
        .accessibilityHint("Opens app preferences")
    }

    // MARK: - Mood Capsule (hero)

    private var moodCapsule: some View {
        GlassCard(style: .elevated, padding: 28, moodTint: vm.moodScore) {
            MoodCapsuleView(moodScore: $vm.moodScore) {
                Haptics.play(.selection)
            }
        }
        .guidedSection(active: .mood, controller: guided, moodScore: vm.moodScore, focus: $guidedA11yFocus)
        .accessibilitySortPriority(3)
    }

    // MARK: - Tags

    private var tagsCard: some View {
        GlassCard(padding: 16, moodTint: vm.moodScore) {
            VStack(alignment: .leading, spacing: 12) {
                Text("What's present?")
                    .font(.rf.headline)
                    .foregroundStyle(Color.rfTextPrimary)
                    .accessibilityAddTraits(.isHeader)

                FlowLayout(spacing: 8) {
                    ForEach(vm.availableTags, id: \.self) { tag in
                        CheckInTagChip(
                            label: tag,
                            isSelected: vm.selectedTags.contains(tag)
                        ) {
                            Haptics.play(.light)
                            vm.toggleTag(tag)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .guidedSection(active: .tags, controller: guided, moodScore: vm.moodScore, focus: $guidedA11yFocus)
        .accessibilitySortPriority(2)
    }

    // MARK: - Note (minimal glass)

    private var noteArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Note")
                .font(.rf.caption)
                .foregroundStyle(Color.rfTextMuted)
                .textCase(.uppercase)
                .tracking(0.8)
                .accessibilityAddTraits(.isHeader)

            TextField(
                "Write a few words about what's happening (optional)…",
                text: $vm.note,
                axis: .vertical
            )
            .lineLimit(3...8)
            .font(.rf.body)
            .foregroundStyle(Color.rfTextPrimary)
            .focused($noteFocused)
            .padding(14)
            .frame(minHeight: 88, maxHeight: 160, alignment: .topLeading)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.rfCardBackground.opacity(0.45))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.rfGlassStroke, lineWidth: 1)
            )
            .accessibilityLabel("Optional note")
            .accessibilityHint("Add a short reflection about how you feel")
        }
        .guidedSection(active: .note, controller: guided, moodScore: vm.moodScore, focus: $guidedA11yFocus)
        .accessibilitySortPriority(1)
    }

    private func scheduleGuidedFocus(for step: GuidedCheckInController.GuidedCheckInStep) {
        guidedA11yFocus = .instruction
        guard let target = step.a11yFocus else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            guidedA11yFocus = target
        }
    }

    // MARK: - Bottom bar

    @ViewBuilder
    private var bottomBar: some View {
        if let guided, guided.step != .summary {
            guidedBottomBar(guided)
        } else {
            standardBottomBar
        }
    }

    private var standardBottomBar: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.35)
            GlassCard(padding: 12, animate: false, moodTint: vm.moodScore) {
                PrimaryButton(
                    title: vm.isEditing ? "Update Entry" : "Seal Check-In",
                    moodScore: vm.moodScore
                ) {
                    noteFocused = false
                    lastSealedMoodScore = vm.moodScore
                    Haptics.play(.success)
                    vm.save()
                }
                .accessibilityLabel(vm.isEditing ? "Update mood entry" : "Save mood check-in")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(.ultraThinMaterial)
    }

    private func guidedBottomBar(_ guided: GuidedCheckInController) -> some View {
        VStack(spacing: 0) {
            Divider().opacity(0.35)
            GlassCard(padding: 12, animate: false, moodTint: vm.moodScore) {
                switch guided.step {
                case .mood:
                    PrimaryButton(title: "Next", moodScore: vm.moodScore) {
                        guided.advanceToTags(reduceMotion: reduceMotion)
                    }
                case .tags:
                    HStack(spacing: 12) {
                        Button("Skip for now") {
                            guided.advanceToNote(reduceMotion: reduceMotion)
                        }
                        .font(.rf.headline)
                        .foregroundStyle(Color.rfTextMuted)
                        .frame(maxWidth: .infinity)
                        .reflectMinimumTapTarget()
                        .accessibilityHint("Continue without selecting tags")

                        PrimaryButton(title: "Next", moodScore: vm.moodScore) {
                            guided.advanceToNote(reduceMotion: reduceMotion)
                        }
                        .frame(maxWidth: .infinity)
                    }
                case .note:
                    PrimaryButton(title: "Save check-in", moodScore: vm.moodScore) {
                        noteFocused = false
                        let entry = vm.sealEntry(persist: true)
                        Haptics.play(.success)
                        ReflectMotion.perform(reduceMotion: reduceMotion) {
                            guided.showSummary(entry: entry, reduceMotion: reduceMotion)
                        }
                    }
                case .summary:
                    EmptyView()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(.ultraThinMaterial)
    }

    // MARK: - Confirmation (standard mode)

    @ViewBuilder
    private var confirmationOverlay: some View {
        if vm.showConfirmation {
            VStack {
                Spacer()
                GlassCard(padding: 14, animate: false, moodTint: lastSealedMoodScore) {
                    Label("Sealed", systemImage: "checkmark.circle.fill")
                        .font(.rf.headline)
                        .foregroundStyle(Color.rfTextPrimary)
                }
                .padding(.horizontal, 48)
                .transition(ReflectMotion.listItem(reduceMotion: reduceMotion))
                .padding(.bottom, 120)
            }
            .accessibilityHidden(true)
            .onAppear {
                AccessibilityNotification.Announcement("Mood entry saved").post()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    ReflectMotion.perform(reduceMotion: reduceMotion) {
                        vm.showConfirmation = false
                    }
                }
            }
        }
    }
}

// MARK: - Check-in tag chip (outline / filled)

struct CheckInTagChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.rf.caption)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? Color.rfTextOnAccent : Color.rfTextPrimary)
                .background {
                    Capsule()
                        .fill(isSelected ? Color.rfAccentPrimary : Color.rfCardBackground.opacity(0.35))
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    isSelected ? Color.clear : Color.rfGlassStroke,
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: isSelected ? Color.black.opacity(0.12) : .clear,
                            radius: 2,
                            x: 0,
                            y: 1
                        )
                }
        }
        .reflectChipTapTarget()
        .reflectPressButtonStyle()
        .animation(ReflectMotion.spring(reduceMotion: reduceMotion), value: isSelected)
        .accessibilityLabel(label)
        .accessibilityHint(isSelected ? "Selected. Double tap to remove" : "Double tap to add")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Flow layout (shared with onboarding)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y),
                anchor: .topLeading,
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }
        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}

// MARK: - Legacy tag chip (onboarding journey)

struct TagChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.rf.caption)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.rfAccentPrimary : Color.rfAccentSubtle)
                .foregroundStyle(isSelected ? Color.rfTextOnAccent : Color.rfTextPrimary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityHint(isSelected ? "Selected. Double tap to remove" : "Double tap to add")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#if DEBUG
#Preview("Check In") {
    CheckInView(vm: CheckInViewModel(store: DesignPreviewProvider.makePreviewMoodStore()))
}

// MARK: Onboarding (guided first check-in)

#Preview("Onboarding – Step 1 Mood") {
    CheckInView(
        vm: CheckInViewModel(store: DesignPreviewProvider.makeEmptyMoodStore()),
        guided: DesignPreviewProvider.guidedController(step: .mood)
    )
}

#Preview("Onboarding – Step 2 Tags") {
    let vm = CheckInViewModel(store: DesignPreviewProvider.makeEmptyMoodStore())
    vm.moodScore = 4
    return CheckInView(
        vm: vm,
        guided: DesignPreviewProvider.guidedController(step: .tags)
    )
}

#Preview("Onboarding – Step 3 Note") {
    let vm = CheckInViewModel(store: DesignPreviewProvider.makeEmptyMoodStore())
    vm.moodScore = 4
    vm.selectedTags = ["friends", "outdoors"]
    return CheckInView(
        vm: vm,
        guided: DesignPreviewProvider.guidedController(step: .note)
    )
}

#Preview("Onboarding – Summary") {
    CheckInView(
        vm: CheckInViewModel(store: DesignPreviewProvider.makeEmptyMoodStore()),
        guided: DesignPreviewProvider.guidedController(
            step: .summary,
            savedEntry: DesignPreviewProvider.sampleFirstCheckInEntry()
        )
    )
}

#Preview("Check In – High Contrast Data") {
    CheckInView(vm: CheckInViewModel(store: DesignPreviewProvider.makeHighContrastMoodStore()))
}
#endif
