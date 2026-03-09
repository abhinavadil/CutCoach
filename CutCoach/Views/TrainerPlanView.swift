import SwiftUI

struct TrainerPlanView: View {
    @State private var selectedSection = 0

    var body: some View {
        ZStack {
            Color.ccBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: CCSpacing.sm) {
                    Text("Trainer Plan")
                        .font(CCFont.display(28, weight: .heavy))
                        .foregroundColor(.ccTextPrimary)
                    Text("Designed for maximum fat loss")
                        .font(CCFont.body(14))
                        .foregroundColor(.ccTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 60)
                .padding(.horizontal, CCSpacing.xl)
                .padding(.bottom, CCSpacing.xl)

                // Segment
                HStack(spacing: 0) {
                    segTab("Nutrition", index: 0)
                    segTab("Workout Split", index: 1)
                    segTab("Rules", index: 2)
                }
                .padding(.horizontal, CCSpacing.xl)
                .padding(.bottom, CCSpacing.xl)

                // Content
                TabView(selection: $selectedSection) {
                    nutritionPlan.tag(0)
                    workoutPlan.tag(1)
                    rulesView.tag(2)
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
                .animation(.spring(response: 0.4), value: selectedSection)
            }
        }
    }

    func segTab(_ title: String, index: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) { selectedSection = index }
        } label: {
            Text(title)
                .font(CCFont.body(13, weight: selectedSection == index ? .semibold : .regular))
                .foregroundColor(selectedSection == index ? .ccBackground : .ccTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(selectedSection == index ? Color.ccAccent : Color.clear)
        }
        .clipShape(RoundedRectangle(cornerRadius: CCRadius.sm))
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: CCRadius.sm)
                .fill(selectedSection == index ? Color.ccAccent : Color.clear)
        )
    }

    // MARK: - Nutrition Plan
    var nutritionPlan: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: CCSpacing.lg) {
                // Macro targets
                macroTargetCard
                    .padding(.horizontal, CCSpacing.xl)

                // Meals
                ForEach(MealPlan.meals) { meal in
                    mealCard(meal)
                        .padding(.horizontal, CCSpacing.xl)
                }

                // Hydration
                hydrationCard
                    .padding(.horizontal, CCSpacing.xl)
            }
            .padding(.bottom, 120)
        }
    }

    var macroTargetCard: some View {
        VStack(spacing: CCSpacing.lg) {
            HStack {
                Text("DAILY TARGETS")
                    .font(CCFont.body(11, weight: .semibold))
                    .foregroundColor(.ccTextTertiary)
                    .tracking(1.2)
                Spacer()
                CCBadge(text: "STRICT", color: .ccRed)
            }

            HStack(spacing: 0) {
                targetCell("Calories", value: "1800–2000", unit: "kcal", color: .ccAccent)
                Divider().frame(width: 0.5).background(Color.ccBorder)
                targetCell("Protein", value: "160–180", unit: "g", color: .ccBlue)
                Divider().frame(width: 0.5).background(Color.ccBorder)
                targetCell("Carbs", value: "150–190", unit: "g", color: .ccOrange)
                Divider().frame(width: 0.5).background(Color.ccBorder)
                targetCell("Fat", value: "40–55", unit: "g", color: .ccPurple)
            }
        }
        .padding(CCSpacing.xl)
        .ccCard()
    }

    func targetCell(_ label: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(CCFont.mono(13, weight: .bold))
                .foregroundColor(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(unit)
                .font(CCFont.body(10))
                .foregroundColor(.ccTextTertiary)
            Text(label)
                .font(CCFont.body(10))
                .foregroundColor(.ccTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CCSpacing.sm)
    }

    func mealCard(_ meal: MealPlan.Meal) -> some View {
        VStack(alignment: .leading, spacing: CCSpacing.lg) {
            // Header
            HStack(spacing: CCSpacing.md) {
                Image(systemName: meal.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.ccAccent)
                    .frame(width: 36, height: 36)
                    .background(Color.ccAccentDim)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    Text(meal.slot)
                        .font(CCFont.display(16, weight: .bold))
                        .foregroundColor(.ccTextPrimary)
                    Text(meal.time)
                        .font(CCFont.body(12))
                        .foregroundColor(.ccTextSecondary)
                }

                Spacer()

                Text(meal.macroHint.components(separatedBy: " · ").first ?? "")
                    .font(CCFont.mono(13, weight: .bold))
                    .foregroundColor(.ccAccent)
            }

            CCDivider()

            // Items
            VStack(alignment: .leading, spacing: CCSpacing.sm) {
                ForEach(meal.items, id: \.self) { item in
                    HStack(spacing: CCSpacing.md) {
                        Circle()
                            .fill(Color.ccAccent)
                            .frame(width: 5, height: 5)
                        Text(item)
                            .font(CCFont.body(14))
                            .foregroundColor(.ccTextSecondary)
                    }
                }
            }

            // Macro hint
            Text(meal.macroHint)
                .font(CCFont.mono(12, weight: .medium))
                .foregroundColor(.ccTextTertiary)
                .padding(.horizontal, CCSpacing.md)
                .padding(.vertical, CCSpacing.sm)
                .background(Color.ccAccentGlow)
                .clipShape(RoundedRectangle(cornerRadius: CCRadius.sm))

            // Coach note
            HStack(alignment: .top, spacing: CCSpacing.sm) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.ccOrange)
                    .padding(.top, 2)
                Text(meal.notes)
                    .font(CCFont.body(13))
                    .foregroundColor(.ccTextSecondary)
                    .lineSpacing(3)
            }
        }
        .padding(CCSpacing.xl)
        .ccCard()
    }

    var hydrationCard: some View {
        HStack(spacing: CCSpacing.xl) {
            Image(systemName: "drop.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.ccBlue)

            VStack(alignment: .leading, spacing: CCSpacing.sm) {
                Text("Water Target")
                    .font(CCFont.display(18, weight: .bold))
                    .foregroundColor(.ccTextPrimary)
                Text("4–5 litres daily. Non-negotiable.")
                    .font(CCFont.body(14))
                    .foregroundColor(.ccTextSecondary)
                Text("Drink consistently through the day. Don't slam it at night.")
                    .font(CCFont.body(12))
                    .foregroundColor(.ccTextTertiary)
                    .lineSpacing(3)
            }
        }
        .padding(CCSpacing.xl)
        .ccCard()
    }

    // MARK: - Workout Plan
    var workoutPlan: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: CCSpacing.lg) {
                // Week overview
                weekOverviewCard
                    .padding(.horizontal, CCSpacing.xl)

                // Day cards
                ForEach(WorkoutPlan.split) { day in
                    dayCard(day)
                        .padding(.horizontal, CCSpacing.xl)
                }
            }
            .padding(.bottom, 120)
        }
    }

    var weekOverviewCard: some View {
        VStack(alignment: .leading, spacing: CCSpacing.lg) {
            Text("5-DAY SPLIT")
                .font(CCFont.body(11, weight: .semibold))
                .foregroundColor(.ccTextTertiary)
                .tracking(1.2)

            HStack(spacing: 0) {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                    let isRest = ["W", "S"].contains(day)
                    VStack(spacing: CCSpacing.sm) {
                        Text(day)
                            .font(CCFont.mono(13, weight: .bold))
                            .foregroundColor(isRest ? .ccTextTertiary : .ccTextPrimary)
                        Circle()
                            .fill(isRest ? Color.ccBorder : Color.ccAccent)
                            .frame(width: 8, height: 8)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            Text("Abs twice per week · Cardio every session · 10k steps daily")
                .font(CCFont.body(12))
                .foregroundColor(.ccTextTertiary)
                .lineSpacing(3)
        }
        .padding(CCSpacing.xl)
        .ccCard()
    }

    func dayCard(_ day: WorkoutPlan.Day) -> some View {
        let isToday = Calendar.current.component(.weekday, from: Date()) == WorkoutPlan.split.firstIndex(where: { $0.day == day.day }).map { $0 + 2 } ?? -1

        return VStack(alignment: .leading, spacing: CCSpacing.lg) {
            HStack(spacing: CCSpacing.md) {
                Image(systemName: day.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isToday ? .ccBackground : .ccAccent)
                    .frame(width: 36, height: 36)
                    .background(isToday ? Color.ccAccent : Color.ccAccentDim)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: CCSpacing.sm) {
                        Text(day.day)
                            .font(CCFont.display(16, weight: .bold))
                            .foregroundColor(.ccTextPrimary)
                        if isToday {
                            CCBadge(text: "TODAY")
                        }
                    }
                    Text(day.focus)
                        .font(CCFont.body(13))
                        .foregroundColor(.ccTextSecondary)
                }

                Spacer()

                if day.absDay {
                    Image(systemName: "figure.core.training")
                        .font(.system(size: 14))
                        .foregroundColor(.ccOrange)
                        .frame(width: 30, height: 30)
                        .background(Color.ccOrange.opacity(0.12))
                        .clipShape(Circle())
                }
            }

            if !day.exercises.isEmpty {
                CCDivider()

                VStack(spacing: 0) {
                    ForEach(day.exercises) { exercise in
                        HStack(spacing: CCSpacing.lg) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(exercise.name)
                                    .font(CCFont.body(14, weight: .medium))
                                    .foregroundColor(.ccTextPrimary)
                                if let note = exercise.note {
                                    Text(note)
                                        .font(CCFont.body(11))
                                        .foregroundColor(.ccTextTertiary)
                                }
                            }
                            Spacer()
                            HStack(spacing: CCSpacing.xs) {
                                Text(exercise.sets)
                                    .font(CCFont.mono(13, weight: .bold))
                                    .foregroundColor(.ccAccent)
                                Text("×")
                                    .font(CCFont.body(12))
                                    .foregroundColor(.ccTextTertiary)
                                Text(exercise.reps)
                                    .font(CCFont.mono(13, weight: .bold))
                                    .foregroundColor(.ccTextSecondary)
                            }
                        }
                        .padding(.vertical, CCSpacing.md)

                        if exercise.id != day.exercises.last?.id {
                            CCDivider()
                        }
                    }
                }
            }
        }
        .padding(CCSpacing.xl)
        .ccCard()
    }

    // MARK: - Rules
    var rulesView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: CCSpacing.lg) {
                ruleCard(
                    number: "01",
                    title: "Hit your protein. Every. Single. Day.",
                    body: "160–180g protein is non-negotiable. Muscle is your metabolism. In a cut this aggressive, protein keeps you from going flat. No excuses.",
                    color: .ccBlue
                )
                ruleCard(
                    number: "02",
                    title: "10,000 steps — not a suggestion.",
                    body: "NEAT (non-exercise activity) burns more calories over a month than your gym sessions. Walk everywhere. Park far. Take the stairs. 10k minimum.",
                    color: .ccGreen
                )
                ruleCard(
                    number: "03",
                    title: "Weigh in every morning.",
                    body: "Same time, same conditions. Post-toilet, pre-food. Track trends not daily numbers. Weight fluctuates — trends don't lie.",
                    color: .ccAccent
                )
                ruleCard(
                    number: "04",
                    title: "Sleep is your secret weapon.",
                    body: "7–8 hours. Sleep deprivation spikes ghrelin (hunger hormone), tanks testosterone, and makes fat loss harder. If you're not sleeping, you're not recovering.",
                    color: .ccPurple
                )
                ruleCard(
                    number: "05",
                    title: "Creatine every day. No gaps.",
                    body: "3–5g post-workout. On rest days too. It takes 3–4 weeks to saturate. One missed day sets you back slightly. Load it and stay loaded.",
                    color: .ccOrange
                )
                ruleCard(
                    number: "06",
                    title: "Log it or it didn't happen.",
                    body: "Accurate logging is the difference between thinking you're eating 1800 calories and actually eating 2400. Weigh your food. Be honest.",
                    color: .ccRed
                )
            }
            .padding(.horizontal, CCSpacing.xl)
            .padding(.bottom, 120)
        }
    }

    func ruleCard(number: String, title: String, body: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: CCSpacing.lg) {
            HStack(alignment: .top) {
                Text(number)
                    .font(CCFont.mono(32, weight: .heavy))
                    .foregroundColor(color.opacity(0.3))
                Spacer()
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 10, height: 10)
                    .padding(.top, 12)
            }

            Text(title)
                .font(CCFont.display(17, weight: .bold))
                .foregroundColor(.ccTextPrimary)
                .lineSpacing(3)

            Text(body)
                .font(CCFont.body(14))
                .foregroundColor(.ccTextSecondary)
                .lineSpacing(4)
        }
        .padding(CCSpacing.xl)
        .background(
            ZStack {
                Color.ccCard
                LinearGradient(
                    colors: [color.opacity(0.06), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: CCRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: CCRadius.lg)
                .stroke(color.opacity(0.2), lineWidth: 0.5)
        )
    }
}
