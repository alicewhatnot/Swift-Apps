//
//  ContentView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 08/03/2026.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var API_KEY: String = "zdWedlYa0U8CeAAcw8Jkb1IOeFGzsWMHOyPvIFAL"
}

struct ContentView: View {
    
    var body: some View {
        TabView {
            APODView()
                .tabItem {
                    Label("APOD", systemImage: "sun.max")
                }
            
            NearEarthObjectsView()
                .tabItem {
                    Label("Asteroids", systemImage: "sparkles")
                }
            
            // This is not very interesting and very badly put together
            // Consider replacing with a non-nasa api or just remove entirely
            // Will still have an events view for the earth events
            // That one is theoretically updated within hours
            SpaceEventsView()
                .tabItem {
                    Label("Space Events", systemImage: "calendar")
                }
            
            EONETView()
                .tabItem {
                    Label("Earth Events", systemImage: "globe")
                }
        }
    }
}

#Preview {
    ContentView()
}


