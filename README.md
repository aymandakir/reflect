# SereneState 🌙

SereneState is an AI-assisted mood journal for iOS that makes emotional check-ins fast, beautiful, and insightful.  
Track how you feel in seconds, visualize your emotional patterns, and reflect with a clean, glassmorphism-inspired interface.

> MVP status: 🚧 In active development – core features are being built.

---

## ✨ Features

- **One-tap mood check-ins** – Log how you feel with a simple slider and a few taps.
- **Emotion tags & notes** – Add context with tags (e.g. “work”, “relationships”, “health”) and optional notes.
- **Trends & insights** – View weekly and monthly charts to understand mood patterns over time.
- **Liquid Glass UI** – Modern glassmorphism-inspired cards and panels with soft blur and depth.
- **Gentle reminders** – Optional local notifications to build a consistent check-in habit.
- **Privacy-first** – All data stored securely on-device by default, with optional cloud sync.

---

## 🧠 Concept & Goals

SereneState is built as a portfolio-quality app to explore:

- **Mental wellbeing UX** – Reduce friction so check-ins take seconds, not minutes.
- **Modern iOS design** – Experiment with Apple’s “Liquid Glass” aesthetic using SwiftUI.
- **Clean architecture** – MVVM + modular structure that’s easy to extend.
- **Backend-ready** – Local-first with an optional Supabase backend for sync (planned).

This project is intentionally scoped as an MVP so new features can be added incrementally.

---

## 🛠 Tech Stack

- **Language:** Swift, SwiftUI
- **Architecture:** MVVM
- **Minimum iOS:** iOS 17+ (adjust as needed)
- **Storage (MVP):** Core Data / SwiftData for local persistence
- **Backend (Planned):** Supabase (Postgres + Auth + Realtime)
- **UI:** SwiftUI, custom blur/overlay components for glassmorphism
- **Charts:** SwiftUI Charts / custom chart components

---

## 📁 Project Structure

```text
SereneState/
  ├─ SereneStateApp.swift
  ├─ Models/
  ├─ ViewModels/
  ├─ Views/
  │   ├─ CheckIn/
  │   ├─ Journal/
  │   └─ Insights/
  ├─ Services/
  │   ├─ Persistence/
  │   └─ Notifications/
  ├─ DesignSystem/
  │   ├─ Colors.swift
  │   ├─ Typography.swift
  │   └─ Components/
  └─ Resources/
      ├─ Assets.xcassets
      └─ Localizable.strings
```

- `DesignSystem` holds color tokens, typography, reusable components (glass cards, buttons, etc.).
- `Services` encapsulates Core Data / SwiftData logic and notification scheduling.

---

## 🧩 Core Screens (MVP)

- **Check-in screen**
  - Mood slider (very low → very high)
  - Emotion tag chips (happy, anxious, focused, tired, etc.)
  - Optional note field
- **Timeline / Journal**
  - List of past entries grouped by day
  - Quick glance of mood score + key tags
- **Insights**
  - Basic line/bar chart of mood over the last 7 / 30 days
  - Simple stats (average mood, streaks, most frequent tags)

---

## 🚀 Getting Started

### Prerequisites

- Xcode VERSION (e.g. 16.x)
- iOS 17+ simulator or device
- Swift 5.9+

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/YOUR_GITHUB_USERNAME/serene-state-ios.git
   cd serene-state-ios
   ```

2. Open the project in Xcode:

   ```bash
   open SereneState.xcodeproj
   # or
   open SereneState.xcworkspace
   ```

3. Build & run on simulator or device (⌘ + R).

### Optional: Supabase Setup (Planned)

> Supabase integration is planned but optional for the MVP.

1. Create a new Supabase project at https://supabase.com
2. Configure tables for `mood_entries` and `tags`
3. Add your Supabase URL and anon key to a `Secrets.xcconfig` file (not committed)
4. Wire up sync in `SupabaseSyncService` (coming soon)

---

## 🧪 Testing

- Unit tests for:
  - MoodEntry model
  - ViewModels (check-in logic, insights calculations)
- Snapshot tests (planned) for key screens with different themes.

Run tests from Xcode (⌘ + U).

---

## 🧱 Roadmap

- [ ] Onboarding flow with explanation of how mood tracking helps
- [ ] Supabase sync for cross-device backups
- [ ] Home screen widgets for quick check-ins
- [ ] WatchOS companion app
- [ ] More advanced insights (trigger analysis by tags)
- [ ] Export data as CSV

---

## 🎨 Design

- **Design style:** Minimal, soft gradients, glassmorphism-inspired cards.
- **Color system:** Neutral background + single accent color, with dark mode support.
- **Typography:** Large, bold titles for mood level, calm body text for entries.

Figma file: `LINK_TO_FIGMA_HERE` (if public).

---

## 📸 Screenshots

> Add screenshots or GIFs here once UI is ready.

| Check-in | Journal | Insights |
|---------|---------|----------|
| IMAGE_1 | IMAGE_2 | IMAGE_3  |

---

## 📄 License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.
