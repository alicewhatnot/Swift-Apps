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
    @Environment(\.accessibilityReduceMotion) var reduceMotion
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
                                        Text("⚠️")
                                            .font(.caption)
                                            .accessibilityLabel("Potentially hazardous")
                                    }
                                    Text(asteroid.name).font(.headline)
                                }
                                Text("Diameter: \(asteroid.diameterKM, specifier: "%.2f") km")
                                    .font(.subheadline)
                                if let distance = approach?.missDistanceKM {
                                    Text("Miss distance: \(distance, specifier: "%.0f") km")
                                        .font(.caption)
                                        .foregroundStyle(.primary.opacity(0.8)) // was default caption grey
                                }
                                if let velocity = approach?.velocityKMPerSecond {
                                    Text("Velocity: \(velocity, specifier: "%.0f") km/s")
                                        .font(.caption)
                                        .foregroundStyle(.primary.opacity(0.8))
                                }
                                if let approachDate = approach?.formattedApproachDate() {
                                    Text("Closest approach: \(approachDate) (\(approach?.timeToApproach ?? ""))")
                                        .font(.caption)
                                        .foregroundStyle(.primary.opacity(0.7)) // was .secondary
                                }
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(accessibilityLabel(for: asteroid, approach: approach))
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
            .defaultBackground(reduceMotion: reduceMotion)
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
                    .accessibilityLabel("Filter asteroids")
                    .accessibilityHint(filter == .potentiallyHazardous ? "Currently showing hazardous only" : "Currently showing all nearby")
                }
            }
            .task { await loadNEOs() }
            .refreshable { await refreshFromNetwork() }
        }
    }

    func accessibilityLabel(for asteroid: NearEarthObject, approach: CloseApproach?) -> String {
        var parts: [String] = [asteroid.name]
        if asteroid.is_potentially_hazardous_asteroid {
            parts.append("potentially hazardous")
        }
        parts.append(String(format: "diameter %.2f kilometres", asteroid.diameterKM))
        if let distance = approach?.missDistanceKM {
            parts.append(String(format: "miss distance %.0f kilometres", distance))
        }
        if let velocity = approach?.velocityKMPerSecond {
            parts.append(String(format: "velocity %.0f kilometres per second", velocity))
        }
        if let date = approach?.formattedApproachDate() {
            parts.append("closest approach \(date)")
        }
        return parts.joined(separator: ", ")
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
