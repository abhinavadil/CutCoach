# Cut Coach — iOS App

Premium fitness accountability app built in SwiftUI for Abhinav's fat-loss transformation.

## Architecture

```
CutCoach/
├── CutCoachApp.swift              # Entry point, SwiftData container
├── Models/
│   └── Models.swift               # SwiftData models + static plans
├── ViewModels/
│   └── AppViewModel.swift         # Central state, coach AI, adherence
├── Views/
│   ├── MainTabView.swift          # Custom tab bar navigation
│   ├── Extensions.swift           # View extensions
│   ├── Onboarding/
│   │   └── OnboardingView.swift   # 4-step onboarding flow
│   ├── Dashboard/
│   │   └── DashboardView.swift    # Main home + ring metrics
│   ├── CheckIn/
│   │   └── CheckInView.swift      # Daily modal check-in
│   ├── MacroTracker/
│   │   └── MacroTrackerView.swift # Food log + macro rings
│   ├── TrainerPlan/
│   │   └── TrainerPlanView.swift  # Meal plan + workout split + rules
│   ├── Progress/
│   │   └── ProgressView.swift     # Charts + heatmap + projections
│   ├── Coach/
│   │   └── CoachView.swift        # AI chat + daily verdict
│   ├── Habits/
│   │   └── HabitsView.swift       # Habit checklist + streak
│   └── Settings/
│       └── SettingsView.swift     # Profile, notifications, targets
└── Components/
    └── DesignSystem.swift         # Colors, typography, reusable UI
```

## Design System

| Token | Value |
|-------|-------|
| Background | `#0A0A0F` |
| Surface | `#131318` |
| Card | `#1C1C24` |
| Accent | `#C8F53C` (Acid Lime) |
| Text Primary | `#F0F0F8` |

## Trainer Plan Embedded

- **Breakfast**: Oats + Whey + Almonds + Apple (~520 kcal)
- **Lunch**: Rice + Veg + Lean Protein (~580 kcal)
- **Pre-Workout**: Yogurt + Nuts + Whey (~320 kcal)
- **Dinner**: Chapati/Rice + Veg + Beans + Egg Whites (~480 kcal)
- **Post-Workout**: Creatine 5g daily
- **Water**: 4–5L daily
- **Steps**: 10,000 minimum
- **Cardio**: Daily requirement
- **Abs**: Twice weekly (Monday + Thursday)
- **Split**: 5-day (Chest/Back/Rest/Shoulders/Legs/Cardio/Rest)

## Macro Targets

| Macro | Target |
|-------|--------|
| Calories | 1800–2000 kcal |
| Protein | 160–180g |
| Carbs | 150–190g |
| Fat | 40–55g |
| Steps | 10,000+ |
| Water | 4–5L |

## How to Build in Xcode

1. Open `CutCoach.xcodeproj` in Xcode 15+
2. Select your development team in Signing & Capabilities
3. Choose iPhone 15 simulator or real device
4. Build & Run (⌘R)

## Minimum Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+
- SwiftData framework
