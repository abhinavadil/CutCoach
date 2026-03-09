import SwiftData
import Foundation

// MARK: - User Profile
@Model
final class UserProfile {
    var id: UUID
    var name: String
    var heightCm: Double
    var startWeightKg: Double
    var goalWeightKg: Double
    var goalDate: Date
    var createdAt: Date

    // Macro targets
    var targetCalories: Int
    var targetProteinG: Int
    var targetCarbsG: Int
    var targetFatG: Int
    var targetSteps: Int
    var targetWaterL: Double
    var targetSleepHours: Double

    init(
        name: String = "Abhinav",
        heightCm: Double = 185.4,
        startWeightKg: Double = 98,
        goalWeightKg: Double = 85,
        goalDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
        targetCalories: Int = 1900,
        targetProteinG: Int = 170,
        targetCarbsG: Int = 170,
        targetFatG: Int = 48,
        targetSteps: Int = 10000,
        targetWaterL: Double = 4.5,
        targetSleepHours: Double = 7.5
    ) {
        self.id = UUID()
        self.name = name
        self.heightCm = heightCm
        self.startWeightKg = startWeightKg
        self.goalWeightKg = goalWeightKg
        self.goalDate = goalDate
        self.createdAt = Date()
        self.targetCalories = targetCalories
        self.targetProteinG = targetProteinG
        self.targetCarbsG = targetCarbsG
        self.targetFatG = targetFatG
        self.targetSteps = targetSteps
        self.targetWaterL = targetWaterL
        self.targetSleepHours = targetSleepHours
    }

    var bmiStart: Double {
        let hm = heightCm / 100
        return startWeightKg / (hm * hm)
    }

    var totalLossKg: Double { startWeightKg - goalWeightKg }
    var daysRemaining: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: goalDate).day ?? 0)
    }
}

// MARK: - Weight Entry
@Model
final class WeightEntry {
    var id: UUID
    var date: Date
    var weightKg: Double
    var note: String

    init(weightKg: Double, date: Date = Date(), note: String = "") {
        self.id = UUID()
        self.weightKg = weightKg
        self.date = date
        self.note = note
    }
}

// MARK: - Daily Log
@Model
final class DailyLog {
    var id: UUID
    var date: Date

    // Macros
    var calories: Int
    var proteinG: Double
    var carbsG: Double
    var fatG: Double

    // Activity
    var steps: Int
    var waterL: Double
    var sleepHours: Double
    var cardioMinutes: Int
    var workoutCompleted: Bool
    var absCompleted: Bool

    // Weight
    var morningWeightKg: Double?

    // Mood & energy
    var moodScore: Int   // 1–5
    var energyScore: Int // 1–5
    var hungerScore: Int // 1–5

    // Adherence
    var coachNote: String
    var adherenceScore: Int // 0–100

    init(date: Date = Date()) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.calories = 0
        self.proteinG = 0
        self.carbsG = 0
        self.fatG = 0
        self.steps = 0
        self.waterL = 0
        self.sleepHours = 0
        self.cardioMinutes = 0
        self.workoutCompleted = false
        self.absCompleted = false
        self.morningWeightKg = nil
        self.moodScore = 3
        self.energyScore = 3
        self.hungerScore = 3
        self.coachNote = ""
        self.adherenceScore = 0
    }

    var macroProgress: Double {
        guard calories > 0 else { return 0 }
        return min(Double(calories) / 1900.0, 1.0)
    }

    var proteinProgress: Double { min(proteinG / 170, 1.0) }
    var carbsProgress: Double   { min(carbsG / 170, 1.0) }
    var fatProgress: Double     { min(fatG / 48, 1.0) }
    var stepsProgress: Double   { min(Double(steps) / 10000, 1.0) }
    var waterProgress: Double   { min(waterL / 4.5, 1.0) }
}

// MARK: - Macro Entry (food log)
@Model
final class MacroEntry {
    var id: UUID
    var date: Date
    var mealSlot: String  // breakfast, lunch, pre_workout, dinner, snack
    var foodName: String
    var calories: Int
    var proteinG: Double
    var carbsG: Double
    var fatG: Double
    var servingSize: String
    var servingCount: Double

    init(
        mealSlot: String,
        foodName: String,
        calories: Int,
        proteinG: Double,
        carbsG: Double,
        fatG: Double,
        servingSize: String = "1 serving",
        servingCount: Double = 1
    ) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: Date())
        self.mealSlot = mealSlot
        self.foodName = foodName
        self.calories = calories
        self.proteinG = proteinG
        self.carbsG = carbsG
        self.fatG = fatG
        self.servingSize = servingSize
        self.servingCount = servingCount
    }
}

// MARK: - Habit Entry
@Model
final class HabitEntry {
    var id: UUID
    var date: Date
    var habits: [String: Bool]  // habit key → completed

    init(date: Date = Date()) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.habits = [:]
    }
}

// MARK: - Static Models (no SwiftData)
struct MealPlan {
    struct Meal: Identifiable {
        let id = UUID()
        let slot: String
        let time: String
        let icon: String
        let items: [String]
        let macroHint: String
        let notes: String
    }

    static let meals: [Meal] = [
        Meal(slot: "Breakfast", time: "7:00–8:00 AM", icon: "sunrise.fill",
             items: ["50g rolled oats", "1 scoop whey protein (chocolate/vanilla)", "20g almonds", "1 apple"],
             macroHint: "~520 kcal · 40g P · 55g C · 14g F",
             notes: "Cook oats with water. Mix whey in post-cooking. Don't skip almonds — healthy fat."),
        Meal(slot: "Lunch", time: "12:30–1:30 PM", icon: "sun.max.fill",
             items: ["150g cooked rice / 2 chapati", "200g vegetables or salad", "150g grilled chicken or paneer"],
             macroHint: "~580 kcal · 45g P · 65g C · 8g F",
             notes: "Prioritise lean protein. Load up vegetables. Keep oil minimal."),
        Meal(slot: "Pre-Workout", time: "4:00–5:00 PM", icon: "bolt.fill",
             items: ["150g low-fat yogurt", "20g mixed nuts", "0.5 scoop whey"],
             macroHint: "~320 kcal · 28g P · 18g C · 12g F",
             notes: "Time it 60–90 min before training. Fuel, not feast."),
        Meal(slot: "Dinner", time: "8:00–9:00 PM", icon: "moon.fill",
             items: ["1 chapati or 100g rice", "200g vegetable curry or salad", "1 cup beans/lentil curry", "3 egg whites"],
             macroHint: "~480 kcal · 38g P · 48g C · 10g F",
             notes: "Keep carbs moderate. Beans are your friend. Egg whites = clean protein."),
        Meal(slot: "Post-Workout", time: "After session", icon: "flask.fill",
             items: ["3–5g creatine monohydrate", "Warm water"],
             macroHint: "0 kcal · Performance supplement",
             notes: "Every single day — training or not. Consistency is the only way creatine works.")
    ]
}

struct WorkoutPlan {
    struct Day: Identifiable {
        let id = UUID()
        let day: String
        let focus: String
        let icon: String
        let exercises: [Exercise]
        let absDay: Bool
    }

    struct Exercise: Identifiable {
        let id = UUID()
        let name: String
        let sets: String
        let reps: String
        let note: String?
    }

    static let split: [Day] = [
        Day(day: "Monday", focus: "Chest + Triceps", icon: "figure.strengthtraining.traditional", exercises: [
            Exercise(name: "Flat Barbell Bench Press", sets: "4", reps: "8–10", note: "Progressive overload"),
            Exercise(name: "Incline Dumbbell Press", sets: "3", reps: "10–12", note: nil),
            Exercise(name: "Cable Flyes", sets: "3", reps: "12–15", note: "Feel the stretch"),
            Exercise(name: "Tricep Rope Pushdown", sets: "4", reps: "12–15", note: nil),
            Exercise(name: "Skull Crushers", sets: "3", reps: "10–12", note: nil)
        ], absDay: true),
        Day(day: "Tuesday", focus: "Back + Biceps", icon: "figure.rowing", exercises: [
            Exercise(name: "Deadlift", sets: "4", reps: "5–6", note: "King lift — own it"),
            Exercise(name: "Pull-Ups / Lat Pulldown", sets: "4", reps: "8–10", note: nil),
            Exercise(name: "Seated Cable Row", sets: "3", reps: "10–12", note: nil),
            Exercise(name: "Barbell Curl", sets: "3", reps: "10–12", note: nil),
            Exercise(name: "Hammer Curls", sets: "3", reps: "12", note: nil)
        ], absDay: false),
        Day(day: "Wednesday", focus: "Rest / Active Recovery", icon: "figure.walk", exercises: [
            Exercise(name: "10,000 steps", sets: "—", reps: "—", note: "Non-negotiable"),
            Exercise(name: "20 min light cardio", sets: "—", reps: "—", note: "Walk or cycle")
        ], absDay: false),
        Day(day: "Thursday", focus: "Shoulders + Core", icon: "figure.arms.open", exercises: [
            Exercise(name: "Overhead Press", sets: "4", reps: "8–10", note: nil),
            Exercise(name: "Lateral Raises", sets: "4", reps: "15–20", note: "Slow, controlled"),
            Exercise(name: "Front Raises", sets: "3", reps: "12", note: nil),
            Exercise(name: "Face Pulls", sets: "3", reps: "15", note: "Rear delt health"),
            Exercise(name: "Abs Circuit", sets: "3", reps: "25 each", note: "Plank / Crunches / Leg Raises")
        ], absDay: true),
        Day(day: "Friday", focus: "Legs", icon: "figure.strengthtraining.functional", exercises: [
            Exercise(name: "Barbell Squat", sets: "4", reps: "8–10", note: "Below parallel"),
            Exercise(name: "Romanian Deadlift", sets: "3", reps: "10–12", note: "Hamstring focus"),
            Exercise(name: "Leg Press", sets: "3", reps: "12–15", note: nil),
            Exercise(name: "Leg Curl", sets: "3", reps: "12", note: nil),
            Exercise(name: "Calf Raises", sets: "4", reps: "20", note: nil)
        ], absDay: false),
        Day(day: "Saturday", focus: "Cardio + Conditioning", icon: "figure.run", exercises: [
            Exercise(name: "HIIT or Steady State Cardio", sets: "1", reps: "30–45 min", note: "Empty stomach preferred"),
            Exercise(name: "10k+ Steps", sets: "—", reps: "—", note: nil)
        ], absDay: false),
        Day(day: "Sunday", focus: "Rest", icon: "moon.stars.fill", exercises: [
            Exercise(name: "Meal prep", sets: "—", reps: "—", note: "Set yourself up for the week"),
            Exercise(name: "Light walk", sets: "—", reps: "—", note: "5,000+ steps minimum")
        ], absDay: false)
    ]
}

struct HabitDefinition: Identifiable {
    let id: String
    let name: String
    let icon: String
    let category: String

    static let all: [HabitDefinition] = [
        HabitDefinition(id: "water_4l",      name: "Drank 4L water",        icon: "drop.fill",          category: "Nutrition"),
        HabitDefinition(id: "protein_hit",   name: "Hit protein target",    icon: "chart.bar.fill",     category: "Nutrition"),
        HabitDefinition(id: "no_cheat",      name: "No off-plan food",      icon: "xmark.shield.fill",  category: "Nutrition"),
        HabitDefinition(id: "steps_10k",     name: "10,000 steps",          icon: "figure.walk",        category: "Activity"),
        HabitDefinition(id: "cardio",        name: "Cardio done",           icon: "figure.run",         category: "Activity"),
        HabitDefinition(id: "workout",       name: "Gym session completed", icon: "dumbbell.fill",      category: "Activity"),
        HabitDefinition(id: "sleep_7",       name: "7+ hrs sleep",          icon: "moon.zzz.fill",      category: "Recovery"),
        HabitDefinition(id: "creatine",      name: "Took creatine",         icon: "flask.fill",         category: "Supplements"),
        HabitDefinition(id: "weighed_in",    name: "Morning weigh-in",      icon: "scalemass.fill",     category: "Tracking"),
        HabitDefinition(id: "logged_meals",  name: "Logged all meals",      icon: "fork.knife",         category: "Tracking"),
    ]
}
