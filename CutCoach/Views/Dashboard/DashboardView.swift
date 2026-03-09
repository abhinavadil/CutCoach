import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appVM: AppViewModel
    @State private var scrollOffset: CGFloat = 0

    var log: DailyLog { appVM.todayLog }
    var profile: UserProfile { appVM.currentProfile }
    var coachMsg: CoachMessage { appVM.coachFeedback(for: log) }
    var adherence: Int { appVM.computeAdherence(log: log) }

    var body: some View {
        ZStack {
            Color.ccBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    dashboardHeader
                        .padding(.top, 60)
                        .padding(.horizontal, CCSpacing.xl)

                    VStack(spacing: CCSpacing.xxl) {
                        // Coach Card
                        coachCard
                            .padding(.horizontal, CCSpacing.xl)

                        // Today Summary Ring
                        todayRingSection
                            .padding(.horizontal, CCSpacing.xl)

                        // Macro Grid
                        macroSection
                            .padding(.horizontal, CCSpacing.xl)

                        // Activity Row
                        activitySection
                            .padding(.horizontal, CCSpacing.xl)

                        // Weight card
                        weightCard
                            .padding(.horizontal, CCSpacing.xl)

                        // Habits quick look
                        habitsQuickLook
                            .padding(.horizontal, CCSpacing.xl)
                    }
                    .padding(.top, CCSpacing.xxl)
                    .padding(.bottom, 120) // tab bar space
                }
            }
        }
    }

    // MARK: - Header
    var dashboardHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(CCFont.body(14))
                    .foregroundColor(.ccTextSecondary)
                Text(profile.name)
                    .font(CCFont.display(28, weight: .heavy))
                    .foregroundColor(.ccTextPrimary)
            }

            Spacer()

            // Streak badge
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.ccAccentDim)
                        .frame(width: 48, height: 48)
                    VStack(spacing: 0) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.ccAccent)
                        Text("7")
                            .font(CCFont.mono(14, weight: .heavy))
                            .foregroundColor(.ccAccent)
                    }
                }
                Text("streak")
                    .font(CCFont.body(10))
                    .foregroundColor(.ccTextTertiary)
            }
        }
    }

    // MARK: - Coach Card
    var coachCard: some View {
        VStack(alignment: .leading, spacing: CCSpacing.lg) {
            HStack(spacing: CCSpacing.md) {
                Image(systemName: coachMsg.toneIcon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(coachMsg.toneColor)

                Text(coachMsg.headline)
                    .font(CCFont.display(17, weight: .bold))
                    .foregroundColor(.ccTextPrimary)

                Spacer()

                CCBadge(text: "\(adherence)%", color: coachMsg.toneColor)
            }

            Text(coachMsg.body)
                .font(CCFont.body(14))
                .foregroundColor(.ccTextSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(CCSpacing.xl)
        .background(
            ZStack {
                Color.ccCard
                LinearGradient(
                    colors: [coachMsg.toneColor.opacity(0.08), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: CCRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: CCRadius.lg)
                .stroke(coachMsg.toneColor.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Today Ring
    var todayRingSection: some View {
        HStack(spacing: CCSpacing.xl) {
            // Big adherence ring
            ZStack {
                CCRingView(progress: Double(adherence) / 100, color: .ccAccent, lineWidth: 10, size: 110)

                VStack(spacing: 2) {
                    Text("\(adherence)")
                        .font(CCFont.mono(32, weight: .heavy))
                        .foregroundColor(.ccAccent)
                    Text("score")
                        .font(CCFont.body(11))
                        .foregroundColor(.ccTextTertiary)
                }
            }

            VStack(spacing: CCSpacing.lg) {
                // Days remaining
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Days Left")
                            .font(CCFont.body(11))
                            .foregroundColor(.ccTextSecondary)
                        Text("\(profile.daysRemaining)")
                            .font(CCFont.mono(22, weight: .bold))
                            .foregroundColor(.ccTextPrimary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Target")
                            .font(CCFont.body(11))
                            .foregroundColor(.ccTextSecondary)
                        Text("\(Int(profile.goalWeightKg)) kg")
                            .font(CCFont.mono(22, weight: .bold))
                            .foregroundColor(.ccAccent)
                    }
                }

                CCDivider()

                // Progress bar
                VStack(alignment: .leading, spacing: CCSpacing.sm) {
                    HStack {
                        Text("Cut Progress")
                            .font(CCFont.body(12))
                            .foregroundColor(.ccTextSecondary)
                        Spacer()
                        Text(String(format: "%.0f%%", appVM.progressPercent * 100))
                            .font(CCFont.mono(12, weight: .bold))
                            .foregroundColor(.ccAccent)
                    }
                    CCProgressBar(value: appVM.progressPercent)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(CCSpacing.xl)
        .ccCard()
    }

    // MARK: - Macro Section
    var macroSection: some View {
        VStack(spacing: CCSpacing.md) {
            CCSectionHeader(title: "Today's Nutrition", action: "Log", onAction: {
                appVM.selectedTab = 1
            })

            // Calories big
            HStack(spacing: CCSpacing.lg) {
                VStack(alignment: .leading, spacing: CCSpacing.sm) {
                    Text("Calories")
                        .font(CCFont.body(12))
                        .foregroundColor(.ccTextSecondary)

                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(log.calories)")
                            .font(CCFont.mono(36, weight: .heavy))
                            .foregroundColor(.ccTextPrimary)
                        Text("/ \(profile.targetCalories)")
                            .font(CCFont.mono(14))
                            .foregroundColor(.ccTextTertiary)
                    }

                    CCProgressBar(value: log.macroProgress, color: calorieColor)
                        .padding(.top, 4)

                    Text("\(max(0, profile.targetCalories - log.calories)) kcal remaining")
                        .font(CCFont.body(11))
                        .foregroundColor(.ccTextTertiary)
                }

                Spacer()

                // Macro rings
                VStack(spacing: CCSpacing.md) {
                    miniMacroRing("P", progress: log.proteinProgress, color: .ccBlue,
                                  value: "\(Int(log.proteinG))g")
                    miniMacroRing("C", progress: log.carbsProgress, color: .ccOrange,
                                  value: "\(Int(log.carbsG))g")
                    miniMacroRing("F", progress: log.fatProgress, color: .ccPurple,
                                  value: "\(Int(log.fatG))g")
                }
            }
            .padding(CCSpacing.xl)
            .ccCard()

            // Macro bars
            HStack(spacing: CCSpacing.md) {
                macroPill("Protein", value: Int(log.proteinG), target: profile.targetProteinG, color: .ccBlue, unit: "g")
                macroPill("Carbs",   value: Int(log.carbsG),   target: profile.targetCarbsG,   color: .ccOrange, unit: "g")
                macroPill("Fat",     value: Int(log.fatG),     target: profile.targetFatG,     color: .ccPurple, unit: "g")
            }
        }
    }

    // MARK: - Activity Section
    var activitySection: some View {
        VStack(spacing: CCSpacing.md) {
            CCSectionHeader(title: "Activity")

            LazyVGrid(columns: [
                GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
            ], spacing: CCSpacing.md) {
                activityTile("Steps",    value: "\(log.steps.formatted())", target: "10,000", icon: "figure.walk", color: .ccGreen, progress: log.stepsProgress)
                activityTile("Water",    value: String(format: "%.1fL", log.waterL), target: "4.5L", icon: "drop.fill", color: .ccBlue, progress: log.waterProgress)
                activityTile("Sleep",    value: String(format: "%.1fh", log.sleepHours), target: "7.5h", icon: "moon.fill", color: .ccPurple, progress: min(log.sleepHours / 7.5, 1.0))
                activityTile("Cardio",   value: "\(log.cardioMinutes)m", target: "30m", icon: "figure.run", color: .ccOrange, progress: min(Double(log.cardioMinutes) / 30.0, 1.0))
                activityTile("Workout",  value: log.workoutCompleted ? "Done" : "Pending", target: "Today", icon: "dumbbell.fill", color: log.workoutCompleted ? .ccGreen : .ccTextTertiary, progress: log.workoutCompleted ? 1 : 0)
                activityTile("Abs",      value: log.absCompleted ? "Done" : "Skip", target: "2x/wk", icon: "figure.core.training", color: log.absCompleted ? .ccGreen : .ccTextTertiary, progress: log.absCompleted ? 1 : 0)
            }
        }
    }

    // MARK: - Weight Card
    var weightCard: some View {
        VStack(spacing: CCSpacing.md) {
            CCSectionHeader(title: "Weight")

            HStack(spacing: CCSpacing.xl) {
                VStack(alignment: .leading, spacing: CCSpacing.sm) {
                    Text("Current")
                        .font(CCFont.body(12))
                        .foregroundColor(.ccTextSecondary)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", appVM.currentWeightKg))
                            .font(CCFont.mono(36, weight: .heavy))
                            .foregroundColor(.ccTextPrimary)
                        Text("kg")
                            .font(CCFont.mono(16))
                            .foregroundColor(.ccTextSecondary)
                    }
                    let lost = profile.startWeightKg - appVM.currentWeightKg
                    Text("↓ \(String(format: "%.1f", lost)) kg lost")
                        .font(CCFont.body(13, weight: .medium))
                        .foregroundColor(.ccGreen)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: CCSpacing.sm) {
                    Text("Goal")
                        .font(CCFont.body(12))
                        .foregroundColor(.ccTextSecondary)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(String(format: "%.0f", profile.goalWeightKg))
                            .font(CCFont.mono(28, weight: .bold))
                            .foregroundColor(.ccAccent)
                        Text("kg")
                            .font(CCFont.mono(14))
                            .foregroundColor(.ccTextSecondary)
                    }
                    Text("\(String(format: "%.1f", appVM.currentWeightKg - profile.goalWeightKg)) kg to go")
                        .font(CCFont.body(12))
                        .foregroundColor(.ccTextTertiary)
                }
            }
            .padding(CCSpacing.xl)
            .ccCard()
        }
    }

    // MARK: - Habits Quick Look
    var habitsQuickLook: some View {
        VStack(spacing: CCSpacing.md) {
            CCSectionHeader(title: "Daily Habits", action: "View All", onAction: {})

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CCSpacing.md) {
                ForEach(HabitDefinition.all.prefix(4)) { habit in
                    HabitTileSmall(habit: habit, completed: Bool.random())
                }
            }
        }
    }

    // MARK: - Helpers
    var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Good morning," }
        if h < 17 { return "Good afternoon," }
        return "Good evening,"
    }

    var calorieColor: Color {
        guard log.calories > 0 else { return .ccTextTertiary }
        let ratio = Double(log.calories) / Double(profile.targetCalories)
        if ratio > 1.1 { return .ccRed }
        if ratio > 0.95 { return .ccAccent }
        return .ccGreen
    }

    func miniMacroRing(_ label: String, progress: Double, color: Color, value: String) -> some View {
        HStack(spacing: CCSpacing.sm) {
            CCRingView(progress: progress, color: color, lineWidth: 4, size: 28)
            VStack(alignment: .leading, spacing: 0) {
                Text(label).font(CCFont.body(10)).foregroundColor(.ccTextTertiary)
                Text(value).font(CCFont.mono(11, weight: .bold)).foregroundColor(color)
            }
        }
    }

    func macroPill(_ name: String, value: Int, target: Int, color: Color, unit: String) -> some View {
        VStack(spacing: CCSpacing.sm) {
            HStack(spacing: 2) {
                Text("\(value)")
                    .font(CCFont.mono(16, weight: .bold))
                    .foregroundColor(color)
                Text(unit)
                    .font(CCFont.mono(11))
                    .foregroundColor(.ccTextTertiary)
            }
            CCProgressBar(value: min(Double(value) / Double(target), 1.0), color: color, height: 4)
            Text(name)
                .font(CCFont.body(11))
                .foregroundColor(.ccTextSecondary)
        }
        .padding(CCSpacing.md)
        .frame(maxWidth: .infinity)
        .ccCard()
    }

    func activityTile(_ title: String, value: String, target: String, icon: String, color: Color, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: CCSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)

            Text(value)
                .font(CCFont.mono(15, weight: .bold))
                .foregroundColor(.ccTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(target)
                .font(CCFont.body(10))
                .foregroundColor(.ccTextTertiary)

            CCProgressBar(value: progress, color: color, height: 3)
        }
        .padding(CCSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ccCard()
    }
}

// MARK: - Ring View
struct CCRingView: View {
    let progress: Double
    var color: Color = .ccAccent
    var lineWidth: CGFloat = 8
    var size: CGFloat = 80
    var backgroundColor: Color = Color.white.opacity(0.08)

    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Habit Tile Small
struct HabitTileSmall: View {
    let habit: HabitDefinition
    let completed: Bool

    var body: some View {
        HStack(spacing: CCSpacing.md) {
            Image(systemName: habit.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(completed ? .ccAccent : .ccTextTertiary)
                .frame(width: 30)

            Text(habit.name)
                .font(CCFont.body(12, weight: .medium))
                .foregroundColor(completed ? .ccTextPrimary : .ccTextSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            Spacer()

            Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundColor(completed ? .ccGreen : .ccTextTertiary)
        }
        .padding(CCSpacing.md)
        .ccCard()
    }
}
