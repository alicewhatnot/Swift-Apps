//
//  ContentView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 08/03/2026.
//

import SwiftData
import SwiftUI

extension EnvironmentValues {
    @Entry var API_KEY: String = {
        Bundle.main.object(forInfoDictionaryKey: "NASA_API_KEY") as? String ?? ""
    }()
}

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @AppStorage("hasSeenNotificationPrompt") var hasSeenNotificationPrompt = false

    var body: some View {
        if !hasSeenNotificationPrompt {
            NotificationPermissionView {
                hasSeenNotificationPrompt = true
                Task {
                    await NotificationService.requestPermission()
                }
            }
        } else {
            TabView {
                APODView()
                    .tabItem {
                        Label("APOD", systemImage: "photo.artframe")
                    }
                    .accessibilityLabel("Astronomy Picture of the Day")

                NearEarthObjectsView()
                    .tabItem {
                        Label("NEOs", systemImage: "bubbles.and.sparkles")
                    }
                    .accessibilityLabel("Near Earth Asteroids")

                SpaceEventsView()
                    .tabItem {
                        Label("Space Events", systemImage: "moon.stars")
                    }

                EONETView()
                    .tabItem {
                        Label("Earth Events", systemImage: "globe.europe.africa")
                    }
            }
        }
    }
}

struct NotificationPermissionView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "bell.badge")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            Text("Stay Ahead of Asteroids")
                .font(.title2.bold())

            Text("SpaceStation will alert you when new hazardous asteroids are detected.\n\nKeep the app in your app switcher to receive alerts in the background.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)

            Button("Enable Notifications") {
                onContinue()
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .preferredColorScheme(.dark)
    }
}
