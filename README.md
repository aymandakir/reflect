# Reflect

Reflect is an AI-assisted mood journal for iOS that makes emotional check-ins fast, beautiful, and insightful.
Track how you feel in seconds, visualize your emotional patterns, and reflect with a clean, glassmorphism-inspired interface.

> MVP status: In active development — core features are being built.

---

## Features

- **One-tap mood check-ins** — Log how you feel with a simple slider and a few taps.
- **Emotion tags & notes** — Add context with tags (e.g. "work", "relationships", "health") and optional notes.
- **Trends & insights** — View weekly and monthly charts to understand mood patterns over time.
- **Liquid Glass UI** — Modern glassmorphism-inspired cards and panels with soft blur and depth.
- **Privacy-first** — All data stored securely on-device by default.

---

## Architecture

| Layer | Folder | Purpose |
|-------|--------|---------|
| **Model** | `Models/` | `MoodEntry` — Codable value type (id, date, score 1–5, tags, note) |
| **Persistence** | `Services/Persistence/` | `MoodStore` — `@Observable` store, JSON file I/O |
| **ViewModels** | `ViewModels/` | One per screen; owns business logic, exposes derived state |
| **Views** | `Views/{CheckIn,Journal,Insights}/` | SwiftUI screens, purely declarative |
| **Design System** | `DesignSystem/` | Color tokens, typography scale, reusable `GlassCard` component |

Pattern: **MVVM** (Model–View–ViewModel)
Platform: iOS 17+, SwiftUI-only, zero external dependencies.

---

## Tech Stack

- **Language:** Swift, SwiftUI
- **Architecture:** MVVM
- **Minimum iOS:** iOS 17+
- **Storage (MVP):** JSON file persistence (swap in SwiftData/CloudKit later)
- **UI:** SwiftUI, custom blur/overlay components for glassmorphism
- **Charts:** Swift Charts framework

---

## Project Structure

```text
Reflect/
  ├─ ReflectApp.swift
  ├─ ContentView.swift
  ├─ Models/
  │   └─ MoodEntry.swift
  ├─ ViewModels/
  │   ├─ CheckInViewModel.swift
  │   ├─ JournalViewModel.swift
  │   └─ InsightsViewModel.swift
  ├─ Views/
  │   ├─ CheckIn/CheckInView.swift
  │   ├─ Journal/JournalView.swift
  │   └─ Insights/InsightsView.swift
  ├─ Services/
  │   └─ Persistence/MoodStore.swift
  ├─ DesignSystem/
  │   ├─ Colors/ColorTokens.swift
  │   ├─ Typography/Typography.swift
  │   └─ Components/GlassCard.swift
  └─ Assets.xcassets/
```

---

## Core Screens (MVP)

1. **Check-In** — Mood score (1–5), emotion tag chips, optional note field, save.
2. **Journal** — Searchable, day-grouped list of past entries with swipe-to-delete.
3. **Insights** — Swift Charts mood trend line, streak counter, average score, top tags.

---

## Design Tokens

The design system lives in `DesignSystem/` and provides:

- **ColorTokens** — Adaptive light/dark palette with programmatic hex fallbacks
- **Typography** — Rounded `.rf.*` font scale (largeTitle through caption)
- **GlassCard** — Frosted-glass container (ultraThinMaterial + transparency + gradient border + soft shadow)

---

## Getting Started

### Prerequisites

- Xcode 16+
- iOS 17+ simulator or device

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/aymandakir/reflect.git
   cd reflect
   ```

2. Open the project in Xcode:

   ```bash
   open Reflect.xcodeproj
   ```

3. Build & run on simulator or device (Cmd+R).

---

## Roadmap

- [ ] Onboarding flow
- [ ] SwiftData migration for richer persistence
- [ ] Supabase sync for cross-device backups
- [ ] Home screen widgets for quick check-ins
- [ ] WatchOS companion app
- [ ] Export data as CSV

---

## Screenshots

> Add screenshots or GIFs here once UI is ready.

| Check-in | Journal | Insights |
|----------|---------|----------|
| IMAGE_1  | IMAGE_2 | IMAGE_3  |

---

## License

This project is licensed under the MIT License.
