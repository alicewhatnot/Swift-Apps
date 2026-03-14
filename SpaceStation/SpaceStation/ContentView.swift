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
                    Label("APOD", systemImage: "photo.artframe")
                }
            
            NearEarthObjectsView()
                .tabItem {
                    Label("Asteroids", systemImage: "bubbles.and.sparkles")
                }
            
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

#Preview {
    ContentView()
}


