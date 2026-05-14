import SwiftUI

/// The mood check-in screen where users record how they feel.
struct CheckInView: View {
    @Bindable var vm: CheckInViewModel

    @State private var animatePulse = false
    @State private var savedBounce = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    moodSelector
                    tagPicker
                    noteField
                    saveButton
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(backgroundGradient)
            .navigationTitle("Check In")
            .overlay(confirmationOverlay)
        }
    }

    // MARK: - Mood Selector

    private var moodSelector: some View {
        GlassCard {
            VStack(spacing: 20) {
                Text("How are you feeling?")
                    .font(.rf.title2)
                    .foregroundStyle(Color.rfTextPrimary)

                let mood = MoodEntry(moodScore: vm.moodScore)
                Text(mood.emoji)
                    .font(.system(.largeTitle, design: .default).weight(.regular))
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                    .scaleEffect(savedBounce ? 1.35 : (animatePulse ? 1.15 : 1.0))
                    .opacity(savedBounce ? 0.0 : 1.0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.5), value: vm.moodScore)
                    .animation(.easeOut(duration: 0.5), value: savedBounce)
                    .accessibilityHidden(true)

                Text(mood.label)
                    .font(.rf.headline)
                    .foregroundStyle(Color.rfTextSecondary)
                    .accessibilityHidden(true)

                moodSlider
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Mood selector")
        }
        .onChange(of: vm.moodScore) { _, _ in
            Haptics.play(.selection)
            withAnimation { animatePulse = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation { animatePulse = false }
            }
        }
    }

    private var moodSlider: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(1...5, id: \.self) { score in
                    let scoreEntry = MoodEntry(moodScore: score)
                    let isSelected = vm.moodScore == score
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            vm.moodScore = score
                        }
                    } label: {
                        Text("\(score)")
                            .font(.rf.headline)
                            .frame(minWidth: 44, minHeight: 44)
                            .background(isSelected ? Color.rfAccent : Color.rfAccentSoft)
                            .foregroundStyle(isSelected ? .white : Color.rfTextPrimary)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Mood \(score) of 5, \(scoreEntry.label)")
                    .accessibilityHint(isSelected ? "Currently selected" : "Double tap to select")
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }

            HStack {
                Text("Awful").font(.rf.caption2)
                Spacer()
                Text("Great").font(.rf.caption2)
            }
            .foregroundStyle(Color.rfTextSecondary)
            .padding(.horizontal, 4)
            .accessibilityHidden(true)
        }
    }

    // MARK: - Tags

    private var tagPicker: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Tags")
                    .font(.rf.headline)
                    .foregroundStyle(Color.rfTextPrimary)

                FlowLayout(spacing: 8) {
                    ForEach(vm.availableTags, id: \.self) { tag in
                        TagChip(
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
    }

    // MARK: - Note

    private var noteField: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Note")
                    .font(.rf.headline)
                    .foregroundStyle(Color.rfTextPrimary)

                TextField("What's on your mind?", text: $vm.note, axis: .vertical)
                    .lineLimit(3...6)
                    .font(.rf.body)
                    .textFieldStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Save

    private var saveButton: some View {
        Button {
            savedBounce = true
            Haptics.play(.success)
            vm.save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                savedBounce = false
            }
        } label: {
            Text(vm.isEditing ? "Update Entry" : "Save Check-In")
                .font(.rf.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.rfAccent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.rfAccent.opacity(0.35), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Confirmation

    @ViewBuilder
    private var confirmationOverlay: some View {
        if vm.showConfirmation {
            VStack {
                Spacer()
                Text("Saved!")
                    .font(.rf.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 32)
            }
            .accessibilityHidden(true)
            .onAppear {
                AccessibilityNotification.Announcement("Mood entry saved").post()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { vm.showConfirmation = false }
                }
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.rfAccent.opacity(0.08), Color.rfBackground],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Tag Chip

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
                .background(isSelected ? Color.rfAccent : Color.rfAccentSoft)
                .foregroundStyle(isSelected ? .white : Color.rfTextPrimary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityHint(isSelected ? "Selected. Double tap to remove" : "Double tap to add")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Flow Layout (Tag Wrapping)

/// A simple wrapping horizontal layout for tags.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            )
            subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

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

// MARK: - Preview

#Preview {
    CheckInView(vm: CheckInViewModel(store: MoodStore()))
}
