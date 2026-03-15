//
//  NotificationService.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 15/03/2026.
//

import Foundation
import UserNotifications
import SwiftData

struct NotificationService {

    // MARK: - Permission

    /// Call once on first launch or from Settings.
    static func requestPermission() async {
        let center = UNUserNotificationCenter.current()
        do {
            try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Notification permission error:", error)
        }
    }

    // MARK: - Check for new hazardous asteroids

    /// Fetches the NEO feed, diffs against seen IDs stored in SwiftData,
    /// fires a notification for each new hazardous object, and updates the seen set.
    @MainActor
    static func checkForNewHazardousAsteroids(
        apiKey: String,
        context: ModelContext
    ) async {
        do {
            // Fetch fresh data (also updates the cache as a side effect)
            let feed = try await CacheService.fetchAndCacheNEOs(apiKey: apiKey, context: context)
            let hazardous = feed.allAsteroids(filterHazardous: true)

            // Load or create the seen-IDs record
            let seenDescriptor = FetchDescriptor<SeenAsteroidIDs>()
            let seenRecords = (try? context.fetch(seenDescriptor)) ?? []
            let seenRecord = seenRecords.first ?? {
                let record = SeenAsteroidIDs()
                context.insert(record)
                return record
            }()

            let seenSet = Set(seenRecord.ids)
            let newAsteroids = hazardous.filter { !seenSet.contains($0.id) }

            // Fire a notification for each new one
            for asteroid in newAsteroids {
                await fireNotification(for: asteroid)
            }
            
            #if DEBUG
            await fireDebugRefreshNotification(
                hazardousCount: hazardous.count,
                newCount: newAsteroids.count
            )
            #endif

            // Update the seen set
            seenRecord.ids = Array(seenSet.union(hazardous.map { $0.id }))
            seenRecord.updatedAt = .now
            try? context.save()

        } catch {
            print("Notification check failed:", error)
        }
    }

    // MARK: - Private

    private static func fireNotification(for asteroid: NearEarthObject) async {
        let center = UNUserNotificationCenter.current()

        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "New Hazardous Asteroid!"
        content.sound = .default

        let approach = asteroid.close_approach_data.first
        let distanceText: String
        if let dist = approach?.missDistanceKM {
            distanceText = "\(Int(dist).formatted()) km"
        } else {
            distanceText = "unknown distance"
        }

        let timeText = approach?.timeToApproach ?? "soon"
        content.body = "\(asteroid.name) passes at \(distanceText) in \(timeText)."
        content.subtitle = "Diameter ~\(String(format: "%.0f", asteroid.diameterKM * 1000)) m"

        // Unique identifier per asteroid so duplicate notifications are suppressed
        let request = UNNotificationRequest(
            identifier: "hazardous-neo-\(asteroid.id)",
            content: content,
            trigger: nil // deliver immediately
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule notification:", error)
        }
    }
    
    // MARK: - Debug

    #if DEBUG
    private static func fireDebugRefreshNotification(hazardousCount: Int, newCount: Int) async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "⚙️ Background Refresh Fired"
        content.body = "Found \(hazardousCount) hazardous NEOs, \(newCount) new."
        content.subtitle = DateFormatter.localizedString(from: .now, dateStyle: .none, timeStyle: .medium)
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "debug-refresh-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        try? await center.add(request)
    }
    #endif
}

