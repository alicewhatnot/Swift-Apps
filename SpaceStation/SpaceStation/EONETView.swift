//
//  EONETView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 12/03/2026.
//

import SwiftUI

struct EONETView: View {

    @State private var events: [EONETEvent] = []
    @State private var selectedCategory: String = "All"

    var availableCategories: [String] {
        ["All"] + Set(events.map { $0.category }).sorted()
    }

    var filteredEvents: [EONETEvent] {
        events.filter { event in
            selectedCategory == "All" || event.category == selectedCategory
        }
    }

    var sortedEvents: [EONETEvent] {
        filteredEvents.sorted(by: {
            $0.latestGeometry?.date ?? .distantPast > $1.latestGeometry?.date ?? .distantPast
        })
    }

    var body: some View {
        NavigationStack {
            Group {
                if !sortedEvents.isEmpty {
                    List(sortedEvents) { event in
                        NavigationLink(destination: EONETEventDetailView(event: event)) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(event.title)
                                        .font(.headline)
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
                } else {
                    ProgressView("Loading events...")
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
                            Button(category) {
                                selectedCategory = category
                            }
                        }
                    } label: {
                        Text("Filter")
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
            }
            .task {
                await loadEvents()
            }
        }
    }

    func loadEvents() async {
        guard let url = URL(string: "https://eonet.gsfc.nasa.gov/api/v2.1/events?days=30") else { return }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try await NetworkService.fetch(from: url, as: EONETResponse.self, decoder: decoder)
            events = response.events
        } catch {
            print(error)
        }
    }
}

#Preview {
    EONETView()
}
