import BackgroundTasks
import Foundation
import SwiftUI

// MARK: - Background Task Manager
final class BackgroundTaskManager {
    static let refreshTaskID    = "com.cutcoach.app.refresh"
    static let processingTaskID = "com.cutcoach.app.processing"

    static func registerTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshTaskID, using: nil) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            handleAppRefresh(task: refreshTask)
        }

        BGTaskScheduler.shared.register(forTaskWithIdentifier: processingTaskID, using: nil) { task in
            guard let processingTask = task as? BGProcessingTask else { return }
            handleProcessing(task: processingTask)
        }
    }

    static func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 min
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }

    static func scheduleProcessing() {
        let request = BGProcessingTaskRequest(identifier: processingTaskID)
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600) // 1 hour
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule processing: \(error)")
        }
    }

    // MARK: - Handlers
    private static func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh() // Reschedule

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let operation = BlockOperation {
            Task { @MainActor in
                // Fetch HealthKit data in background
                await HealthKitManager.shared.fetchAllTodayData()

                // Update widget
                let hkManager = HealthKitManager.shared
                WidgetDataWriter.write(
                    calories: 0, // Would come from SwiftData
                    targetCalories: 1900,
                    proteinG: 0,
                    targetProteinG: 170,
                    steps: hkManager.todaySteps,
                    adherenceScore: 0,
                    currentWeightKg: hkManager.latestWeight ?? 98,
                    goalWeightKg: 85,
                    daysRemaining: 23,
                    coachLine: "Keep grinding. Every day counts."
                )
            }
        }

        task.expirationHandler = { operation.cancel() }
        queue.addOperation(operation)

        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }
    }

    private static func handleProcessing(task: BGProcessingTask) {
        scheduleProcessing()

        Task { @MainActor in
            // Compute weekly stats, streak analysis, projections
            // Trigger coach nudge if needed
            task.setTaskCompleted(success: true)
        }
    }
}

// MARK: - App Lifecycle Integration
extension CutCoachApp {
    // Call in scenePhase .background:
    // BackgroundTaskManager.scheduleAppRefresh()
    // BackgroundTaskManager.scheduleProcessing()
}
