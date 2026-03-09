import SwiftUI
import SwiftData
import UserNotifications

@main
struct CutCoachApp: App {
    @StateObject private var appVM             = AppViewModel()
    @StateObject private var notificationMgr   = NotificationManager.shared
    @StateObject private var healthMgr         = HealthKitManager.shared
    @Environment(\.scenePhase) private var scenePhase

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([UserProfile.self, DailyLog.self, MacroEntry.self, HabitEntry.self, WeightEntry.self])
        // Try App Group container for widget sharing, fall back to standard
        if let config = try? ModelConfiguration(schema: schema, isStoredInMemoryOnly: false,
                                                 groupContainer: .identifier("group.com.cutcoach.app")) {
            if let container = try? ModelContainer(for: schema, configurations: [config]) { return container }
        }
        return try! ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema)])
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appVM)
                .environmentObject(notificationMgr)
                .environmentObject(healthMgr)
                .modelContainer(sharedModelContainer)
                .preferredColorScheme(.dark)
                .onAppear { Task { await setupApp() } }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { syncWidgetData() }
            if phase == .active { Task { await healthMgr.fetchAllTodayData() } }
        }
    }

    private func setupApp() async {
        NotificationManager.registerCategories()
        BackgroundTaskManager.registerTasks()
        _ = await notificationMgr.requestAuthorization()
        if UserDefaults.standard.bool(forKey: "healthKitEnabled") {
            _ = await healthMgr.requestAuthorization()
        }
    }

    private func syncWidgetData() {
        WidgetDataWriter.write(
            calories: appVM.todayLog.calories,
            targetCalories: appVM.currentProfile.targetCalories,
            proteinG: appVM.todayLog.proteinG,
            targetProteinG: Double(appVM.currentProfile.targetProteinG),
            steps: appVM.todayLog.steps,
            adherenceScore: appVM.computeAdherence(log: appVM.todayLog),
            currentWeightKg: appVM.currentWeightKg,
            goalWeightKg: appVM.currentProfile.goalWeightKg,
            daysRemaining: appVM.currentProfile.daysRemaining,
            coachLine: appVM.coachFeedback(for: appVM.todayLog).headline
        )
    }
}

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    var body: some View {
        Group {
            if hasCompletedOnboarding { MainTabView() } else { OnboardingView() }
        }
        .animation(.easeInOut(duration: 0.4), value: hasCompletedOnboarding)
    }
}
