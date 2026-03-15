//
//  NearEarthObjectsView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 08/03/2026.
//

import SwiftUI
import SwiftData

struct NearEarthObjectsView: View {
    @Environment(\.API_KEY) var api_key
    @Environment(\.modelContext) var modelContext
    @Query private var cachedFeeds: [CachedNEOFeed]

    @State private var neoFeed: NEOFeed?
    @State private var isLoading = true
    @State private var loadError = false

    enum Filter { case all, potentiallyHazardous }
    @State private var filter: Filter = .potentiallyHazardous

    var body: some View {
        NavigationStack {
            Group {
                if let neoFeed {
                    let asteroids = neoFeed.allAsteroids(filterHazardous: filter == .potentiallyHazardous)
                    List(asteroids) { asteroid in
                        let approach = asteroid.close_approach_data.first
                        NavigationLink(destination: NearEarthObjectDetailView(asteroid: asteroid)) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    if asteroid.is_potentially_hazardous_asteroid && filter == .all {
                                        Text("⚠️").font(.caption)
                                    }
                                    Text(asteroid.name).font(.headline)
                                }
                                Text("Diameter: \(asteroid.diameterKM, specifier: "%.2f") km")
                                    .font(.subheadline)
                                if let distance = approach?.missDistanceKM {
                                    Text("Miss distance: \(distance, specifier: "%.0f") km")
                                        .font(.caption)
                                }
                                if let velocity = approach?.velocityKMPerSecond {
                                    Text("Velocity: \(velocity, specifier: "%.0f") km/s")
                                        .font(.caption)
                                }
                                if let approachDate = approach?.formattedApproachDate() {
                                    Text("Closest approach: \(approachDate) (\(approach?.timeToApproach ?? ""))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .listRowBackground(Color.black.opacity(0.5))
                    }
                } else if isLoading {
                    ProgressView("Loading asteroids...")
                } else {
                    ContentUnavailableView(
                        "No Data",
                        systemImage: "antenna.radiowaves.left.and.right",
                        description: Text("Could not load NEO data.")
                    )
                }
            }
            .defaultBackground(withStreaks: true)
            .navigationTitle("Near Earth Objects")
            .scrollContentBackground(.hidden)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem {
                    Menu {
                        Picker("Filter", selection: $filter) {
                            Text("Hazardous").tag(Filter.potentiallyHazardous)
                            Text("All Nearby").tag(Filter.all)
                        }
                    } label: {
                        HStack {
                            Text("Filter")
                            Image(systemName: "line.horizontal.3.decrease")
                        }
                    }
                }
            }
            .task { await loadNEOs() }
            .refreshable { await refreshFromNetwork() }
        }
    }

    func loadNEOs() async {
        if let cached = cachedFeeds.first {
            let feed = try? JSONDecoder().decode(NEOFeed.self, from: cached.jsonData)
            if let feed {
                neoFeed = feed
                isLoading = false
                if cached.isStale { await refreshFromNetwork() }
                return
            }
        }
        await refreshFromNetwork()
    }

    func refreshFromNetwork() async {
        do {
            neoFeed = try await CacheService.fetchAndCacheNEOs(
                apiKey: api_key,
                context: modelContext
            )
        } catch {
            print("Failed to load NEOs:", error)
            loadError = true
        }
        isLoading = false
    }
}
