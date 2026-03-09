# Cut Coach — Complete Setup Guide

## ─── Project Structure (Full) ───────────────────────────────────────────────

```
CutCoach/
├── CutCoach/                          # Main App Target
│   ├── CutCoachApp.swift              # Entry point, lifecycle, integrations
│   ├── Models/
│   │   └── Models.swift               # SwiftData models + trainer plan data
│   ├── ViewModels/
│   │   └── AppViewModel.swift         # Central state, adherence, coach AI
│   ├── Views/
│   │   ├── MainTabView.swift          # Custom tab bar + toast
│   │   ├── Extensions.swift           # View extensions
│   │   ├── Onboarding/OnboardingView.swift
│   │   ├── Dashboard/DashboardView.swift
│   │   ├── CheckIn/CheckInView.swift
│   │   ├── MacroTracker/MacroTrackerView.swift
│   │   ├── TrainerPlan/TrainerPlanView.swift
│   │   ├── Progress/ProgressView.swift
│   │   ├── Coach/CoachView.swift
│   │   ├── Habits/HabitsView.swift
│   │   └── Settings/SettingsView.swift
│   ├── Components/
│   │   └── DesignSystem.swift         # Full design token system
│   ├── Utilities/
│   │   ├── NotificationManager.swift  # All reminders + coach nudges
│   │   ├── HealthKitManager.swift     # Apple Health read/write
│   │   ├── DataService.swift          # SwiftData abstraction + CSV export
│   │   └── BackgroundTaskManager.swift# Background refresh + processing
│   └── Resources/
│       ├── Info.plist                 # HealthKit + notification permissions
│       └── GenerateAssets.swift       # Asset generation helper
│
├── CutCoachWidget/                    # Widget Extension Target
│   └── CutCoachWidget.swift           # Small + Medium home screen widgets
│
└── README.md
```

## ─── Build Steps ─────────────────────────────────────────────────────────────

### 1. Create Xcode Project
```
File → New → Project → App
Product Name: CutCoach
Bundle ID: com.cutcoach.app
Interface: SwiftUI
Language: Swift
Storage: SwiftData
```

### 2. Add Widget Extension
```
File → New → Target → Widget Extension
Product Name: CutCoachWidget
Include Configuration Intent: NO
```

### 3. Enable Capabilities (Main Target)
In Signing & Capabilities tab:
- ✅ HealthKit
- ✅ Push Notifications
- ✅ Background Modes → Background fetch, Background processing
- ✅ App Groups → group.com.cutcoach.app

### 4. Enable Capabilities (Widget Target)
- ✅ App Groups → group.com.cutcoach.app (SAME group as main app)

### 5. Copy Source Files
Copy all .swift files from this archive into your Xcode project, 
maintaining the folder structure shown above.

### 6. Configure Info.plist
The provided Info.plist includes:
- NSHealthShareUsageDescription
- NSHealthUpdateUsageDescription
- BGTaskSchedulerPermittedIdentifiers
- UIBackgroundModes

### 7. Set Deployment Target
- iOS 17.0 minimum
- iPhone only (portrait)

## ─── Design System ───────────────────────────────────────────────────────────

| Token          | Value      | Usage                    |
|----------------|------------|--------------------------|
| ccBackground   | #0A0A0F    | Root backgrounds         |
| ccSurface      | #131318    | Tab bar, nav bar         |
| ccCard         | #1C1C24    | All card backgrounds     |
| ccCardElevated | #242430    | Nested cards             |
| ccBorder       | #2A2A38    | All borders/dividers     |
| ccAccent       | #C8F53C    | Primary CTA, rings       |
| ccGreen        | #34D399    | Success states           |
| ccRed          | #F87171    | Error/strict coach       |
| ccOrange       | #FB923C    | Warning/neutral coach    |
| ccBlue         | #60A5FA    | Protein macro            |
| ccPurple       | #A78BFA    | Fat macro                |
| ccTextPrimary  | #F0F0F8    | Main text                |
| ccTextSecondary| #8888A8    | Secondary text           |
| ccTextTertiary | #55556A    | Labels, captions         |

## ─── Trainer Plan (Embedded) ─────────────────────────────────────────────────

| Meal         | Time          | Items                                      | Macros          |
|-------------|---------------|--------------------------------------------|-----------------|
| Breakfast   | 7:00–8:00 AM  | Oats + Whey + Almonds + Apple              | ~520 kcal 40P   |
| Lunch       | 12:30–1:30 PM | Rice + Veg + Lean Protein                  | ~580 kcal 45P   |
| Pre-Workout | 4:00–5:00 PM  | Yogurt + Nuts + Whey                       | ~320 kcal 28P   |
| Dinner      | 8:00–9:00 PM  | Chapati + Veg + Beans + Egg Whites         | ~480 kcal 38P   |
| Post-WO     | After session | Creatine 5g + water                        | 0 kcal          |

**Daily Targets**: 1800–2000 kcal · 160–180g P · 150–190g C · 40–55g F

## ─── Notification Schedule ───────────────────────────────────────────────────

| Time    | Notification                  |
|---------|-------------------------------|
| 7:00 AM | Morning weigh-in              |
| 7:30 AM | Breakfast reminder            |
| 9:00 AM | Water check (first)           |
| 11:00 AM| Water check                   |
| 12:30 PM| Lunch time                    |
| 1:00 PM | Water check                   |
| 3:00 PM | Water check                   |
| 4:00 PM | Pre-workout meal              |
| 5:00 PM | Workout reminder 💪           |
| 6:00 PM | Steps check (10k target)      |
| 7:00 PM | Water check                   |
| 7:30 PM | Post-workout / creatine       |
| 8:00 PM | Dinner reminder               |
| 8:30 PM | Evening log reminder          |
| 9:00 PM | Final water check             |

## ─── Future Roadmap ──────────────────────────────────────────────────────────

### Phase 2 (Next Sprint)
- [ ] Live food barcode scanner (Vision framework)
- [ ] OpenAI / Claude API integration for real AI coaching
- [ ] Apple Watch app (workout tracking)
- [ ] Apple Health automatic sync (steps, sleep auto-fill)
- [ ] Siri Shortcuts ("Log my lunch")
- [ ] iCloud sync across devices

### Phase 3
- [ ] Coach photo progress comparison
- [ ] Body measurements tracker (chest, waist, hips)
- [ ] Custom meal templates
- [ ] Social accountability partner
- [ ] Trainer-client mode (coach reviews logs)

## ─── AI Coach Integration ────────────────────────────────────────────────────

The CoachView is ready for real AI. Replace `coachResponse(for:)` with:

```swift
func coachResponse(for query: String) async -> String {
    let response = try await anthropic.messages.create(
        model: "claude-sonnet-4-6",
        maxTokens: 200,
        system: """
            You are a strict, supportive personal transformation coach for Abhinav.
            He is 6'1", cutting from 98kg to 85kg in 30 days.
            Targets: 1900 kcal, 170g protein, 10k steps, 4.5L water.
            Tone: concise, practical, no fluff. Max 2 sentences.
            Current adherence: \(adherence)%. Today's stats: \(todayStats).
        """,
        messages: [.init(role: .user, content: query)]
    )
    return response.content.first?.text ?? ""
}
```

## ─── Requirements ────────────────────────────────────────────────────────────

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+
- Real device recommended for HealthKit + notifications
