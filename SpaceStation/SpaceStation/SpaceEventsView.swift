//
//  SpaceEventsView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 11/03/2026.
//

import SwiftUI

struct SpaceEvent: Identifiable {
    let id: String
    let type: String
    let date: String
    let detail: String
}

struct SpaceEventsView: View {
    @State private var events = [SpaceEvent]()
    @State private var isLoading = true
    @Environment(\.API_KEY) var api_key

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading space events...")
                } else {
                    List(events.sorted { $0.date > $1.date }) { event in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.type)
                                .font(.headline)
                            Text(event.date)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(event.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.black.opacity(0.5))
                    }
                }
                
            }
            .navigationTitle("Past Events")
            
            .defaultBackground(withStreaks: true)
            
            .scrollContentBackground(.hidden)
            .preferredColorScheme(.dark)
            .task {
                await loadAllEvents()
            }
        }
    }

    func loadAllEvents() async {
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-604_800)
        let start = dateToString(startDate)
        let end = dateToString(endDate)
        let key = api_key

        let endpoints: [(String, String)] = [
            ("Coronal Mass Ejection",       "https://api.nasa.gov/DONKI/CME?startDate=\(start)&endDate=\(end)&api_key=\(key)"),
            ("Geomagnetic Storm",           "https://api.nasa.gov/DONKI/GST?startDate=\(start)&endDate=\(end)&api_key=\(key)"),
            ("Interplanetary Shock",        "https://api.nasa.gov/DONKI/IPS?startDate=\(start)&endDate=\(end)&catalog=ALL&api_key=\(key)"),
            ("Solar Flare",                 "https://api.nasa.gov/DONKI/FLR?startDate=\(start)&endDate=\(end)&api_key=\(key)"),
            ("Solar Energetic Particle",    "https://api.nasa.gov/DONKI/SEP?startDate=\(start)&endDate=\(end)&api_key=\(key)"),
            ("Magnetopause Crossing",       "https://api.nasa.gov/DONKI/MPC?startDate=\(start)&endDate=\(end)&api_key=\(key)"),
            ("Radiation Belt Enhancement",  "https://api.nasa.gov/DONKI/RBE?startDate=\(start)&endDate=\(end)&api_key=\(key)"),
            ("High Speed Stream",           "https://api.nasa.gov/DONKI/HSS?startDate=\(start)&endDate=\(end)&api_key=\(key)")
        ]

        var allEvents = [SpaceEvent]()

        await withTaskGroup(of: [SpaceEvent].self) { group in
            for (type, urlString) in endpoints {
                guard let url = URL(string: urlString) else { continue }
                group.addTask {
                    await fetchEvents(type: type, from: url)
                }
            }
            for await result in group {
                allEvents.append(contentsOf: result)
            }
        }

        events = allEvents.sorted { $0.date > $1.date }
        isLoading = false
    }

    func fetchEvents(type: String, from url: URL) async -> [SpaceEvent] {
        do {
            let data = try await NetworkService.fetch(from: url, as: [[String: AnyCodable]].self)
            return data.compactMap { dict -> SpaceEvent? in
                let date: String = dict["startTime"]?.stringValue
                    ?? dict["time21_5"]?.stringValue
                    ?? dict["eventTime"]?.stringValue
                    ?? "Unknown date"

                let rawID: String? = dict["activityID"]?.stringValue
                    ?? dict["gstID"]?.stringValue
                    ?? dict["sepID"]?.stringValue
                let id: String = rawID
                    ?? dict["mpcID"]?.stringValue
                    ?? dict["rbeID"]?.stringValue
                    ?? dict["hssID"]?.stringValue
                    ?? UUID().uuidString

                let detail: String = dict["note"]?.stringValue
                    ?? dict["catalog"]?.stringValue
                    ?? dict["link"]?.stringValue
                    ?? ""

                return SpaceEvent(id: id, type: type, date: date, detail: detail)
            }
        } catch {
            print("Failed to load \(type):", error)
            return []
        }
    }

    func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct AnyCodable: Codable {
    let value: Any

    var stringValue: String? { value as? String }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let s = try? container.decode(String.self) { value = s }
        else if let i = try? container.decode(Int.self) { value = i }
        else if let d = try? container.decode(Double.self) { value = d }
        else if let b = try? container.decode(Bool.self) { value = b }
        else { value = "" }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let s = value as? String { try container.encode(s) }
    }
}

#Preview {
    SpaceEventsView()
}
