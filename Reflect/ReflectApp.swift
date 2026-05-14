// ──────────────────────────────────────────────────────────────
// Reflect — A Mood Journal App
// ──────────────────────────────────────────────────────────────
//
// ARCHITECTURE OVERVIEW
// =====================
//
// Pattern:   MVVM (Model–View–ViewModel)
// Platform:  iOS 17+, SwiftUI-only, zero external dependencies.
// Design:    "Liquid Glass" / glassmorphism — translucent cards,
//            soft blur, subtle borders, and adaptive light/dark.
//
// Layers
// ------
//  Models/              → MoodEntry (Codable value type)
//  Services/Persistence → MoodStore (@Observable, JSON file I/O)
//  ViewModels/          → One per screen, owns business logic
//  Views/               → SwiftUI screens (CheckIn, Journal, Insights)
//  DesignSystem/        → Color tokens, typography scale, GlassCard
//
// Navigation
// ----------
//  TabView with three tabs:
//    1. Check-In  — create / edit a mood entry
//    2. Journal   — searchable list grouped by day
//    3. Insights  — Swift Charts trend line, stats, top tags
//
// Persistence
// -----------
//  MoodStore persists entries as JSON in the documents directory.
//  Swap in SwiftData / CloudKit later by conforming to the same API.
//
// ──────────────────────────────────────────────────────────────

import SwiftUI

@main
struct ReflectApp: App {
    @State private var store = MoodStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
