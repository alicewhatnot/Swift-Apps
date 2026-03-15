//
//  BackgroundTaskService.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 15/03/2026.
//

import Foundation
import BackgroundTasks
import SwiftData

struct BackgroundTaskService {

    static let taskIdentifier = "com.spacestation.neo-refresh"

    // MARK: - Registration
    // Call from your App's init() or AppDelegate's didFinishLaunching,
    // BEFORE the app finishes launching.

    static func registerBackgroundTask(
        apiKey: String,
        modelContainer: ModelContainer
    ) {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            handleBackgroundRefresh(task: refreshTask, apiKey: apiKey, modelContainer: modelContainer)
        }
    }

    // MARK: - Scheduling
    // Call after each successful run (and on app foreground) to keep the task alive.

    static func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        // Ask to be woken at least every 3 hours
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60 * 3)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule background refresh:", error)
        }
    }

    // MARK: - Handler

    private static func handleBackgroundRefresh(
        task: BGAppRefreshTask,
        apiKey: String,
        modelContainer: ModelContainer
    ) {
        // Reschedule immediately so we keep getting woken up
        scheduleBackgroundRefresh()

        let context = ModelContext(modelContainer)

        let taskHandle = Task {
            await NotificationService.checkForNewHazardousAsteroids(
                apiKey: apiKey,
                context: context
            )
            task.setTaskCompleted(success: true)
        }

        // If the OS cancels the task, cancel our work too
        task.expirationHandler = {
            taskHandle.cancel()
            task.setTaskCompleted(success: false)
        }
    }
}
