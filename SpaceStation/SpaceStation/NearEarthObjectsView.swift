//
//  SwiftUIView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 08/03/2026.
//

import SwiftUI

struct NearEarthObjectsView: View {
    @Environment(\.API_KEY) var api_key
    @State private var neoFeed: NEOFeed?
    
    enum Filter {
        case all, potentiallyHazardous
    }
    @State private var filter: Filter = .potentiallyHazardous

    var body: some View {
        NavigationStack {
            let asteroids = neoFeed?.allAsteroids(filterHazardous: filter == .potentiallyHazardous) ?? []
            
            List(asteroids) { asteroid in
                let approach = asteroid.close_approach_data.first
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        if asteroid.is_potentially_hazardous_asteroid && filter == .all {
                            Text("⚠️")
                                .font(.caption)
                        }
                        Text(asteroid.name)
                            .font(.headline)
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
                .listRowBackground(Color.black.opacity(0.5))
            }
            .background(
                Image("stars")
                    .resizable()
                    .opacity(0.5)
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .navigationTitle("Cataclysmic Events")
            .scrollContentBackground(.hidden)
            .preferredColorScheme(.dark)
            .task {
                await loadNEOs()
            }
            .toolbar {
                Menu("Sort", systemImage: "line.horizontal.3.decrease") {
                    Picker("Filter", selection: $filter) {
                        Text("Show Hazardous").tag(Filter.potentiallyHazardous)
                        Text("Show All Nearby").tag(Filter.all)
                    }
                }
            }
        }
    }

    func loadNEOs() async {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(604800)

        guard let url = URL(
            string: "https://api.nasa.gov/neo/rest/v1/feed?start_date=\(dateToString(startDate))&end_date=\(dateToString(endDate))&api_key=\(api_key)"
        ) else {
            print("Invalid URL")
            return
        }

        do {
            neoFeed = try await NetworkService.fetch(from: url, as: NEOFeed.self)
        } catch {
            print("Failed to load NEOs:", error)
        }
    }

    func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

#Preview {
    NearEarthObjectsView()
}
