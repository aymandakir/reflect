import SwiftUI

/// Lightweight app preferences sheet.
struct SettingsView: View {
    @AppStorage(Haptics.userDefaultsKey) private var hapticsEnabled = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $hapticsEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Haptics")
                                    .font(.rf.body)
                                    .foregroundStyle(Color.rfTextPrimary)
                                Text("Tactile feedback when you select moods and save check-ins.")
                                    .font(.rf.caption)
                                    .foregroundStyle(Color.rfTextMuted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        } icon: {
                            Image(systemName: "waveform")
                                .foregroundStyle(Color.rfAccentPrimary)
                        }
                    }
                    .accessibilityHint("Double tap to turn haptic feedback on or off")
                } header: {
                    Text("Feedback")
                }

                Section {
                    placeholderRow(
                        title: "Daily reminder",
                        systemImage: "bell",
                        hint: "Coming soon"
                    )
                    placeholderRow(
                        title: "Export data",
                        systemImage: "square.and.arrow.up",
                        hint: "Coming soon"
                    )
                } header: {
                    Text("More")
                } footer: {
                    Text("Reminders and export will be available in a future update.")
                        .font(.rf.caption)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.rf.headline)
                        .reflectMinimumTapTarget()
                        .accessibilityLabel("Done")
                        .accessibilityHint("Closes settings")
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func placeholderRow(title: String, systemImage: String, hint: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.rf.body)
                .foregroundStyle(Color.rfTextMuted)
                .frame(width: 28)
                .accessibilityHidden(true)

            Text(title)
                .font(.rf.body)
                .foregroundStyle(Color.rfTextMuted)

            Spacer()

            Text("Soon")
                .font(.rf.caption)
                .foregroundStyle(Color.rfTextMuted.opacity(0.8))
        }
        .padding(.vertical, 4)
        .disabled(true)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), unavailable")
        .accessibilityHint(hint)
    }
}

#Preview {
    SettingsView()
}
