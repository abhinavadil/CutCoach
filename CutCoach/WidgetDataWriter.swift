import Foundation
import WidgetKit

// MARK: - Widget Data Writer (shared data between main app and widget)
struct WidgetDataWriter {
    static func write(
        calories: Int,
        targetCalories: Int,
        proteinG: Double,
        targetProteinG: Double,
        steps: Int,
        adherenceScore: Int,
        currentWeightKg: Double,
        goalWeightKg: Double,
        daysRemaining: Int,
        coachLine: String
    ) {
        let defaults = UserDefaults(suiteName: "group.com.cutcoach.app") ?? .standard
        defaults.set(calories,          forKey: "widget_calories")
        defaults.set(targetCalories,    forKey: "widget_target_calories")
        defaults.set(proteinG,          forKey: "widget_protein")
        defaults.set(targetProteinG,    forKey: "widget_target_protein")
        defaults.set(steps,             forKey: "widget_steps")
        defaults.set(adherenceScore,    forKey: "widget_adherence")
        defaults.set(currentWeightKg,   forKey: "widget_current_weight")
        defaults.set(goalWeightKg,      forKey: "widget_goal_weight")
        defaults.set(daysRemaining,     forKey: "widget_days_remaining")
        defaults.set(coachLine,         forKey: "widget_coach_line")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
