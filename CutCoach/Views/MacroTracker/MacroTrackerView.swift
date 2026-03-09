import SwiftUI

struct MacroTrackerView: View {
    @EnvironmentObject var appVM: AppViewModel
    @State private var showAddFood = false
    @State private var selectedMeal = "Breakfast"

    let meals = ["Breakfast", "Lunch", "Pre-Workout", "Dinner", "Snack"]

    // Sample food entries for display
    @State private var foodLog: [FoodLogEntry] = FoodLogEntry.sampleData()

    var totalCals: Int { foodLog.reduce(0) { $0 + $1.calories } }
    var totalProtein: Double { foodLog.reduce(0) { $0 + $1.proteinG } }
    var totalCarbs: Double { foodLog.reduce(0) { $0 + $1.carbsG } }
    var totalFat: Double { foodLog.reduce(0) { $0 + $1.fatG } }

    let profile = UserProfile()

    var body: some View {
        ZStack {
            Color.ccBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Fixed header
                macroHeader
                    .padding(.top, 60)
                    .padding(.horizontal, CCSpacing.xl)
                    .padding(.bottom, CCSpacing.xl)

                // Macro rings summary
                macroRingsSummary
                    .padding(.horizontal, CCSpacing.xl)
                    .padding(.bottom, CCSpacing.xl)

                // Meal scroll
                ScrollView(showsIndicators: false) {
                    VStack(spacing: CCSpacing.xxl) {
                        // Meal selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: CCSpacing.sm) {
                                ForEach(meals, id: \.self) { meal in
                                    mealChip(meal)
                                }
                            }
                            .padding(.horizontal, CCSpacing.xl)
                        }

                        // Food entries by meal
                        VStack(spacing: CCSpacing.lg) {
                            ForEach(meals, id: \.self) { meal in
                                let entries = foodLog.filter { $0.mealSlot == meal }
                                if !entries.isEmpty {
                                    mealSection(meal: meal, entries: entries)
                                }
                            }
                        }
                        .padding(.horizontal, CCSpacing.xl)

                        // Trainer meal suggestions
                        planSuggestions
                            .padding(.horizontal, CCSpacing.xl)
                    }
                    .padding(.bottom, 120)
                }
            }
        }
        .sheet(isPresented: $showAddFood) {
            AddFoodSheet(mealSlot: selectedMeal) { entry in
                foodLog.append(entry)
            }
        }
    }

    // MARK: - Header
    var macroHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Macro Tracker")
                    .font(CCFont.display(24, weight: .heavy))
                    .foregroundColor(.ccTextPrimary)
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .font(CCFont.body(13))
                    .foregroundColor(.ccTextSecondary)
            }

            Spacer()

            Button {
                selectedMeal = "Snack"
                showAddFood = true
            } label: {
                HStack(spacing: CCSpacing.sm) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                    Text("Add Food")
                        .font(CCFont.body(14, weight: .semibold))
                }
                .foregroundColor(.ccBackground)
                .padding(.horizontal, CCSpacing.lg)
                .padding(.vertical, CCSpacing.md)
                .background(Color.ccAccent)
                .clipShape(Capsule())
                .ccGlow()
            }
        }
    }

    // MARK: - Macro Rings
    var macroRingsSummary: some View {
        HStack(spacing: 0) {
            // Calories center
            VStack(spacing: CCSpacing.sm) {
                ZStack {
                    CCRingView(progress: min(Double(totalCals) / 1900, 1.0), color: .ccAccent, lineWidth: 12, size: 90)
                    VStack(spacing: 0) {
                        Text("\(totalCals)")
                            .font(CCFont.mono(22, weight: .heavy))
                            .foregroundColor(.ccTextPrimary)
                        Text("kcal")
                            .font(CCFont.body(10))
                            .foregroundColor(.ccTextTertiary)
                    }
                }
                Text("Calories")
                    .font(CCFont.body(12))
                    .foregroundColor(.ccTextSecondary)
                Text("\(max(0, 1900 - totalCals)) left")
                    .font(CCFont.mono(11, weight: .bold))
                    .foregroundColor(.ccAccent)
            }
            .frame(maxWidth: .infinity)

            // Macros
            ForEach([
                (name: "Protein", val: totalProtein, target: 170.0, color: Color.ccBlue),
                (name: "Carbs",   val: totalCarbs,   target: 170.0, color: Color.ccOrange),
                (name: "Fat",     val: totalFat,     target: 48.0,  color: Color.ccPurple)
            ], id: \.name) { macro in
                VStack(spacing: CCSpacing.sm) {
                    ZStack {
                        CCRingView(progress: min(macro.val / macro.target, 1.0), color: macro.color, lineWidth: 8, size: 64)
                        Text("\(Int(macro.val))g")
                            .font(CCFont.mono(12, weight: .bold))
                            .foregroundColor(.ccTextPrimary)
                    }
                    Text(macro.name)
                        .font(CCFont.body(11))
                        .foregroundColor(.ccTextSecondary)
                    Text("/ \(Int(macro.target))g")
                        .font(CCFont.mono(10))
                        .foregroundColor(.ccTextTertiary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(CCSpacing.xl)
        .ccCard()
    }

    // MARK: - Meal chip
    func mealChip(_ meal: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) { selectedMeal = meal }
            selectedMeal = meal
        } label: {
            Text(meal)
                .font(CCFont.body(14, weight: selectedMeal == meal ? .semibold : .regular))
                .foregroundColor(selectedMeal == meal ? .ccBackground : .ccTextSecondary)
                .padding(.horizontal, CCSpacing.lg)
                .padding(.vertical, CCSpacing.sm + 2)
                .background(selectedMeal == meal ? Color.ccAccent : Color.ccCard)
                .clipShape(Capsule())
                .overlay(selectedMeal == meal ? nil : Capsule().stroke(Color.ccBorder, lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Meal Section
    func mealSection(meal: String, entries: [FoodLogEntry]) -> some View {
        VStack(alignment: .leading, spacing: CCSpacing.md) {
            HStack {
                Text(meal.uppercased())
                    .font(CCFont.body(11, weight: .semibold))
                    .foregroundColor(.ccTextTertiary)
                    .tracking(1.2)

                Spacer()

                Button {
                    selectedMeal = meal
                    showAddFood = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.ccAccent)
                }

                let mealCals = entries.reduce(0) { $0 + $1.calories }
                Text("\(mealCals) kcal")
                    .font(CCFont.mono(12, weight: .bold))
                    .foregroundColor(.ccTextSecondary)
            }

            VStack(spacing: 1) {
                ForEach(entries) { entry in
                    foodRow(entry)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: CCRadius.md))
        }
    }

    func foodRow(_ entry: FoodLogEntry) -> some View {
        HStack(spacing: CCSpacing.lg) {
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.name)
                    .font(CCFont.body(14, weight: .medium))
                    .foregroundColor(.ccTextPrimary)
                Text(entry.serving)
                    .font(CCFont.body(12))
                    .foregroundColor(.ccTextSecondary)
            }

            Spacer()

            HStack(spacing: CCSpacing.lg) {
                macroChip("\(Int(entry.proteinG))g", color: .ccBlue)
                macroChip("\(Int(entry.carbsG))g",   color: .ccOrange)
                macroChip("\(Int(entry.fatG))g",     color: .ccPurple)
                Text("\(entry.calories)")
                    .font(CCFont.mono(13, weight: .bold))
                    .foregroundColor(.ccTextPrimary)
                    .frame(width: 36, alignment: .trailing)
            }
        }
        .padding(CCSpacing.lg)
        .background(Color.ccCard)
        .overlay(alignment: .bottom) {
            CCDivider().padding(.horizontal, CCSpacing.lg)
        }
    }

    func macroChip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(CCFont.mono(11, weight: .bold))
            .foregroundColor(color)
            .frame(width: 34, alignment: .trailing)
    }

    // MARK: - Plan Suggestions
    var planSuggestions: some View {
        VStack(alignment: .leading, spacing: CCSpacing.md) {
            CCSectionHeader(title: "Trainer Meals", subtitle: "Your plan")

            ForEach(MealPlan.meals.prefix(3)) { meal in
                HStack(spacing: CCSpacing.lg) {
                    Image(systemName: meal.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.ccAccent)
                        .frame(width: 36, height: 36)
                        .background(Color.ccAccentDim)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(meal.slot)
                            .font(CCFont.body(14, weight: .semibold))
                            .foregroundColor(.ccTextPrimary)
                        Text(meal.items.prefix(2).joined(separator: " · "))
                            .font(CCFont.body(12))
                            .foregroundColor(.ccTextSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text(meal.macroHint.components(separatedBy: " · ").first ?? "")
                        .font(CCFont.mono(12, weight: .bold))
                        .foregroundColor(.ccAccent)
                }
                .padding(CCSpacing.lg)
                .ccCard()
            }
        }
    }
}

// MARK: - Data Models
struct FoodLogEntry: Identifiable {
    let id = UUID()
    var mealSlot: String
    var name: String
    var serving: String
    var calories: Int
    var proteinG: Double
    var carbsG: Double
    var fatG: Double

    static func sampleData() -> [FoodLogEntry] {
        [
            FoodLogEntry(mealSlot: "Breakfast", name: "Rolled Oats", serving: "50g", calories: 180, proteinG: 6, carbsG: 30, fatG: 3),
            FoodLogEntry(mealSlot: "Breakfast", name: "Whey Protein", serving: "1 scoop (30g)", calories: 120, proteinG: 24, carbsG: 4, fatG: 2),
            FoodLogEntry(mealSlot: "Breakfast", name: "Almonds", serving: "20g", calories: 116, proteinG: 4, carbsG: 4, fatG: 10),
            FoodLogEntry(mealSlot: "Lunch", name: "Chicken Breast", serving: "150g cooked", calories: 248, proteinG: 46, carbsG: 0, fatG: 5),
            FoodLogEntry(mealSlot: "Lunch", name: "Brown Rice", serving: "150g cooked", calories: 195, proteinG: 4, carbsG: 42, fatG: 1),
            FoodLogEntry(mealSlot: "Lunch", name: "Mixed Vegetables", serving: "200g", calories: 70, proteinG: 3, carbsG: 14, fatG: 0),
        ]
    }
}

// MARK: - Add Food Sheet
struct AddFoodSheet: View {
    @Environment(\.dismiss) var dismiss
    let mealSlot: String
    let onAdd: (FoodLogEntry) -> Void

    @State private var name = ""
    @State private var serving = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ccBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: CCSpacing.xl) {
                        VStack(spacing: CCSpacing.md) {
                            CCTextField(label: "Food Name", placeholder: "e.g. Chicken Breast", text: $name, icon: "fork.knife")
                            CCTextField(label: "Serving Size", placeholder: "e.g. 150g", text: $serving, icon: "scalemass.fill")
                        }

                        VStack(spacing: CCSpacing.md) {
                            CCSectionHeader(title: "Macros")

                            HStack(spacing: CCSpacing.md) {
                                CCNumberField(label: "Calories", value: $calories, icon: "flame.fill")
                                CCNumberField(label: "Protein (g)", value: $protein, icon: "chart.bar.fill")
                            }
                            HStack(spacing: CCSpacing.md) {
                                CCNumberField(label: "Carbs (g)", value: $carbs, icon: "leaf.fill")
                                CCNumberField(label: "Fat (g)", value: $fat, icon: "drop.fill")
                            }
                        }

                        CCPrimaryButton("Add to \(mealSlot)", icon: "plus.circle.fill") {
                            let entry = FoodLogEntry(
                                mealSlot: mealSlot,
                                name: name.isEmpty ? "Food Item" : name,
                                serving: serving.isEmpty ? "1 serving" : serving,
                                calories: Int(calories) ?? 0,
                                proteinG: Double(protein) ?? 0,
                                carbsG: Double(carbs) ?? 0,
                                fatG: Double(fat) ?? 0
                            )
                            onAdd(entry)
                            dismiss()
                        }
                    }
                    .padding(CCSpacing.xl)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add Food")
                        .font(CCFont.display(16, weight: .bold))
                        .foregroundColor(.ccTextPrimary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.ccAccent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
