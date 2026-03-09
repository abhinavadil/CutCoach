import UserNotifications
import Foundation

// MARK: - Notification Manager
@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private init() {
        Task { await checkStatus() }
    }

    // MARK: - Permission
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            await checkStatus()
            if granted { scheduleAllReminders() }
            return granted
        } catch {
            print("Notification auth error: \(error)")
            return false
        }
    }

    func checkStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    // MARK: - Schedule All
    func scheduleAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        scheduleMorningWeighIn()
        scheduleMealReminders()
        scheduleWorkoutReminder()
        scheduleEveningLogReminder()
        scheduleWaterReminder()
        scheduleStepsReminder()
    }

    // MARK: - Morning Weigh-In
    private func scheduleMorningWeighIn() {
        let content = UNMutableNotificationContent()
        content.title = "Morning Check-In"
        content.body = "Weigh yourself now. Same time, same conditions. Data or excuses — pick one."
        content.sound = .default
        content.interruptionLevel = .active
        content.categoryIdentifier = "WEIGH_IN"

        var components = DateComponents()
        components.hour = 7
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "morning_weigh_in",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Meal Reminders
    private func scheduleMealReminders() {
        let meals: [(id: String, hour: Int, minute: Int, title: String, body: String)] = [
            ("breakfast",    7, 30, "Breakfast Time", "Oats + Whey + Almonds + Apple. 520 kcal. Start the day right."),
            ("lunch",       12, 30, "Lunch Time", "Rice + Lean Protein + Veg. Stay on plan."),
            ("preworkout",  16,  0, "Pre-Workout Window", "Yogurt + Nuts + Whey. Fuel up 60-90 min before training."),
            ("dinner",      20,  0, "Dinner Time", "Chapati + Veg + Beans + Egg Whites. Keep carbs moderate tonight."),
            ("postworkout", 19, 30, "Post-Workout", "Take your creatine. 5g. Every day — no gaps.")
        ]

        for meal in meals {
            let content = UNMutableNotificationContent()
            content.title = meal.title
            content.body = meal.body
            content.sound = .default
            content.categoryIdentifier = "MEAL"

            var components = DateComponents()
            components.hour = meal.hour
            components.minute = meal.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: "meal_\(meal.id)",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)
        }
    }

    // MARK: - Workout Reminder
    private func scheduleWorkoutReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Gym Time, Abhinav"
        content.body = "13 kg doesn't lose itself. Get in the gym."
        content.sound = UNNotificationSound(named: UNNotificationSoundName("workout_alert.caf"))
        content.interruptionLevel = .timeSensitive

        var components = DateComponents()
        components.hour = 17
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "workout_reminder",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Evening Log
    private func scheduleEveningLogReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Log Your Day"
        content.body = "You can't manage what you don't measure. Log it all — honest numbers only."
        content.sound = .default
        content.categoryIdentifier = "LOG_REMINDER"

        var components = DateComponents()
        components.hour = 20
        components.minute = 30

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "evening_log",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Water Reminder (every 2 hours between 9am–8pm)
    private func scheduleWaterReminder() {
        let hours = [9, 11, 13, 15, 17, 19]
        let messages = [
            "Water check. Where are you at? Target: 4.5L.",
            "Drink water. Hydration = performance + fat loss.",
            "Afternoon water check. Still 4L minimum today.",
            "Pre-workout hydration window. Fill that bottle.",
            "Evening hydration. Don't slam 2L at night — drink it now.",
            "Final water check. Hit your 4.5L?"
        ]

        for (i, hour) in hours.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "💧 Water Reminder"
            content.body = messages[i]
            content.sound = .default

            var components = DateComponents()
            components.hour = hour
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: "water_\(hour)",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)
        }
    }

    // MARK: - Steps Reminder
    private func scheduleStepsReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Step Count Check"
        content.body = "Under 10k? You've got time. Walk it out — NEAT is your fat-loss edge."
        content.sound = .default

        var components = DateComponents()
        components.hour = 18
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "steps_check",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Streak Alert
    func scheduleStreakAlert(streak: Int) {
        let content = UNMutableNotificationContent()
        if streak == 7 {
            content.title = "🔥 7-Day Streak"
            content.body = "One week of consistency. This is where transformation begins. Don't break it."
        } else if streak == 14 {
            content.title = "🏆 Two-Week Warrior"
            content.body = "14 days locked in. You're building identity now, not just habits."
        } else if streak == 30 {
            content.title = "💪 30 Days. Mission Complete."
            content.body = "You did it. Every day. Review your progress — and set the next target."
        } else {
            return
        }
        content.sound = .defaultCritical

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "streak_\(streak)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Coach Nudge (triggered when adherence drops)
    func sendCoachNudge(adherenceScore: Int) {
        guard adherenceScore < 50 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Coach Check-In"

        let messages = [
            "Today's adherence is slipping. You're not behind yet — but you will be if this continues.",
            "Protein low. Steps low. This isn't the plan. Pull it back together tonight.",
            "One bad day doesn't ruin a cut. A bad week does. Get back on track now."
        ]
        content.body = messages.randomElement() ?? messages[0]
        content.sound = .default
        content.interruptionLevel = .active

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(
            identifier: "coach_nudge_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Cancel
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}

// MARK: - Notification Categories Setup
extension NotificationManager {
    static func registerCategories() {
        let checkInAction = UNNotificationAction(
            identifier: "OPEN_CHECKIN",
            title: "Check In Now",
            options: .foreground
        )
        let logAction = UNNotificationAction(
            identifier: "OPEN_LOG",
            title: "Log Meal",
            options: .foreground
        )
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Dismiss",
            options: .destructive
        )

        let weighInCategory = UNNotificationCategory(
            identifier: "WEIGH_IN",
            actions: [checkInAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        let mealCategory = UNNotificationCategory(
            identifier: "MEAL",
            actions: [logAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        let logCategory = UNNotificationCategory(
            identifier: "LOG_REMINDER",
            actions: [checkInAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            weighInCategory, mealCategory, logCategory
        ])
    }
}
