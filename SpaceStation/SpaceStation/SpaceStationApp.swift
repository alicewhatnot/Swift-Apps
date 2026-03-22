//
//  SpaceStationApp.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 08/03/2026.
//

import SwiftUI
import SwiftData

@main
struct SpaceStationApp: App {
    @Environment(\.API_KEY) var api_key

    // Single shared container for all cache models
    let modelContainer: ModelContainer = {
        let schema = Schema([
            CachedNEOFeed.self,
            CachedEONETFeed.self,
            CachedAPOD.self,
            CachedSpaceEvents.self,
            SeenAsteroidIDs.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // Background task must be registered before app finishes launching.
        // API key isn't available in init() via @Environment, so we read it
        // from wherever you store it (UserDefaults, Info.plist, etc.).
        // Replace the string below with however you access your key at init time.
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "NASA_API_KEY") as? String ?? ""

        BackgroundTaskService.registerBackgroundTask(
            apiKey: apiKey,
            modelContainer: modelContainer
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: UIApplication.didBecomeActiveNotification
                    )
                ) { _ in
                    let apiKey = Bundle.main.object(forInfoDictionaryKey: "NASA_API_KEY") as? String ?? ""
                    Task {
                        let context = modelContainer.mainContext
                        await NotificationService.checkForNewHazardousAsteroids(
                            apiKey: apiKey,
                            context: context
                        )
                        BackgroundTaskService.scheduleBackgroundRefresh()
                    }
                }
        }
    }
}
