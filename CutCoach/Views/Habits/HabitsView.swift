import SwiftUI

struct HabitsView: View {
    @State private var completedHabits: Set<String> = ["water_4l", "workout"]
    @State private var streak = 7

    var completedCount: Int { completedHabits.count }
    var totalCount: Int { HabitDefinition.all.count }
    var completionRate: Double { Double(completedCount) / Double(totalCount) }

    var body: some View {
        ZStack {
            Color.ccBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: CCSpacing.xxl) {
                    // Header
                    habitHeader
                        .padding(.top, 60)
                        .padding(.horizontal, CCSpacing.xl)

                    // Progress ring
                    completionRing
                        .padding(.horizontal, CCSpacing.xl)

                    // Habit list by category
                    ForEach(habitCategories, id: \.self) { category in
                        categorySection(category)
                            .padding(.horizontal, CCSpacing.xl)
                    }

                    // Streak card
                    streakCard
                        .padding(.horizontal, CCSpacing.xl)
                }
                .padding(.bottom, 120)
            }
        }
    }

    var habitCategories: [String] {
        Array(Set(HabitDefinition.all.map { $0.category })).sorted()
    }

    // MARK: - Header
    var habitHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Habits")
                    .font(CCFont.display(28, weight: .heavy))
                    .foregroundColor(.ccTextPrimary)
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .font(CCFont.body(14))
                    .foregroundColor(.ccTextSecondary)
            }
            Spacer()
            CCBadge(text: "\(completedCount)/\(totalCount)", color: completionRate >= 0.8 ? .ccGreen : .ccOrange)
        }
    }

    // MARK: - Completion Ring
    var completionRing: some View {
        HStack(spacing: CCSpacing.xxl) {
            ZStack {
                CCRingView(progress: completionRate, color: .ccAccent, lineWidth: 14, size: 120)
                VStack(spacing: 2) {
                    Text("\(Int(completionRate * 100))%")
                        .font(CCFont.mono(30, weight: .heavy))
                        .foregroundColor(completionRate >= 0.8 ? .ccAccent : .ccOrange)
                    Text("today")
                        .font(CCFont.body(12))
                        .foregroundColor(.ccTextTertiary)
                }
            }

            VStack(alignment: .leading, spacing: CCSpacing.lg) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Habits Done")
                        .font(CCFont.body(12))
                        .foregroundColor(.ccTextSecondary)
                    Text("\(completedCount) of \(totalCount)")
                        .font(CCFont.mono(22, weight: .bold))
                        .foregroundColor(.ccTextPrimary)
                }

                CCDivider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Streak")
                        .font(CCFont.body(12))
                        .foregroundColor(.ccTextSecondary)
                    HStack(spacing: CCSpacing.sm) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.ccOrange)
                        Text("\(streak) days")
                            .font(CCFont.mono(22, weight: .bold))
                            .foregroundColor(.ccTextPrimary)
                    }
                }
            }
        }
        .padding(CCSpacing.xl)
        .ccCard()
    }

    // MARK: - Category Section
    func categorySection(_ category: String) -> some View {
        let habits = HabitDefinition.all.filter { $0.category == category }

        return VStack(alignment: .leading, spacing: CCSpacing.md) {
            Text(category.uppercased())
                .font(CCFont.body(11, weight: .semibold))
                .foregroundColor(.ccTextTertiary)
                .tracking(1.2)

            VStack(spacing: 0) {
                ForEach(habits) { habit in
                    HabitRow(
                        habit: habit,
                        isCompleted: completedHabits.contains(habit.id)
                    ) {
                        toggleHabit(habit.id)
                    }

                    if habit.id != habits.last?.id {
                        CCDivider().padding(.horizontal, CCSpacing.lg)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: CCRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: CCRadius.lg)
                    .stroke(Color.ccBorder, lineWidth: 0.5)
            )
            .background(Color.ccCard.clipShape(RoundedRectangle(cornerRadius: CCRadius.lg)))
        }
    }

    // MARK: - Streak Card
    var streakCard: some View {
        VStack(spacing: CCSpacing.lg) {
            HStack {
                Text("CONSISTENCY MATTERS")
                    .font(CCFont.body(11, weight: .semibold))
                    .foregroundColor(.ccTextTertiary)
                    .tracking(1.2)
                Spacer()
            }

            HStack(spacing: CCSpacing.sm) {
                ForEach(0..<14) { i in
                    let isCompleted = i < streak
                    RoundedRectangle(cornerRadius: 3)
                        .fill(isCompleted ? Color.ccAccent : Color.ccBorder)
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                }
            }

            Text(streakMessage)
                .font(CCFont.body(14))
                .foregroundColor(.ccTextSecondary)
                .lineSpacing(3)
        }
        .padding(CCSpacing.xl)
        .ccCard()
    }

    var streakMessage: String {
        if streak >= 14 { return "Two weeks of consistency. This is becoming identity, not just habit." }
        if streak >= 7  { return "7 days in. You've built momentum — don't break it now." }
        if streak >= 3  { return "3 days strong. Early days. Show up again tomorrow." }
        return "Every streak starts at 1. Make today count."
    }

    func toggleHabit(_ id: String) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        withAnimation(.spring(response: 0.3)) {
            if completedHabits.contains(id) {
                completedHabits.remove(id)
            } else {
                completedHabits.insert(id)
                if completedHabits.count == totalCount {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
        }
    }
}

// MARK: - Habit Row
struct HabitRow: View {
    let habit: HabitDefinition
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: CCSpacing.lg) {
                // Icon
                Image(systemName: habit.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isCompleted ? .ccBackground : .ccAccent)
                    .frame(width: 36, height: 36)
                    .background(isCompleted ? Color.ccAccent : Color.ccAccentDim)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .animation(.spring(response: 0.3), value: isCompleted)

                // Label
                VStack(alignment: .leading, spacing: 3) {
                    Text(habit.name)
                        .font(CCFont.body(15, weight: .medium))
                        .foregroundColor(isCompleted ? .ccTextPrimary : .ccTextSecondary)
                        .strikethrough(isCompleted, color: .ccTextTertiary)

                    Text(habit.category)
                        .font(CCFont.body(11))
                        .foregroundColor(.ccTextTertiary)
                }

                Spacer()

                // Checkmark
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.ccGreen : Color.ccBorder.opacity(0.3))
                        .frame(width: 28, height: 28)

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.ccBackground)
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.6), value: isCompleted)
            }
            .padding(.horizontal, CCSpacing.lg)
            .padding(.vertical, CCSpacing.lg)
        }
        .buttonStyle(.plain)
    }
}
