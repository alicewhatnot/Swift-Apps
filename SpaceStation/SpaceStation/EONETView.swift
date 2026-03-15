//
//  EONETView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 12/03/2026.
//

import SwiftUI
import SwiftData

struct EONETView: View {
    @Environment(\.modelContext) var modelContext
    @Query private var cachedFeeds: [CachedEONETFeed]

    @State private var events: [EONETEvent] = []
    @State private var isLoading = true
    @State private var selectedCategory: String = "All"

    var availableCategories: [String] {
        ["All"] + Set(events.map { $0.category }).sorted()
    }

    var filteredEvents: [EONETEvent] {
        events.filter { selectedCategory == "All" || $0.category == selectedCategory }
    }

    var sortedEvents: [EONETEvent] {
        filteredEvents.sorted {
            $0.latestGeometry?.date ?? .distantPast > $1.latestGeometry?.date ?? .distantPast
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if !sortedEvents.isEmpty {
                    List(sortedEvents) { event in
                        NavigationLink(destination: EONETEventDetailView(event: event)) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(event.title).font(.headline)
                                    Spacer()
                                    if event.isClosed {
                                        Text("Closed")
                                            .font(.caption)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(.red.opacity(0.3))
                                            .cornerRadius(6)
                                    }
                                }
                                Text(event.category)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                if let geometry = event.latestGeometry {
                                    Text(geometry.date, style: .date)
                                        .font(.caption)
                                        .opacity(0.7)
                                }
                                if let description = event.description {
                                    Text(description)
                                        .font(.caption)
                                        .lineLimit(2)
                                        .opacity(0.8)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color.black.opacity(0.5))
                    }
                } else if isLoading {
                    ProgressView("Loading events...")
                } else {
                    ContentUnavailableView(
                        "No Events",
                        systemImage: "antenna.radiowaves.left.and.right",
                        description: Text("No Earth events found.")
                    )
                }
            }
            .defaultBackground(withStreaks: true)
            .scrollContentBackground(.hidden)
            .preferredColorScheme(.dark)
            .navigationTitle("Earth Events")
            .toolbar {
                ToolbarItem {
                    NavigationLink {
                        EONETMapView(events: filteredEvents)
                    } label: {
                        HStack {
                            Text("Show Events")
                            Image(systemName: "map")
                        }
                    }
                }
                ToolbarItem {
                    Menu {
                        ForEach(availableCategories, id: \.self) { category in
                            Button(category) { selectedCategory = category }
                        }
                    } label: {
                        Text("Filter")
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
            }
            .task { await loadEvents() }
            .refreshable { await refreshFromNetwork() }
        }
    }

    func loadEvents() async {
        if let cached = cachedFeeds.first, !cached.isStale {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let response = try? decoder.decode(EONETResponse.self, from: cached.jsonData) {
                events = response.events
                isLoading = false
                return
            }
        }
        await refreshFromNetwork()
    }

    func refreshFromNetwork() async {
        do {
            let response = try await CacheService.fetchAndCacheEONET(context: modelContext)
            events = response.events
        } catch {
            print("Failed to load EONET:", error)
        }
        isLoading = false
    }
}
