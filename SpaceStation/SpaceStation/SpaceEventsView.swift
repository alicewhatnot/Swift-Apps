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
    let date: String        // formatted display string
    let rawDate: String     // ISO 8601 for sorting
    let detail: String
    // Extra fields — populated where available
    let classType: String?      // Solar flares: "M1.1", "C2.0" etc.
    let sourceLocation: String? // e.g. "N10W70"
    let peakTime: String?       // Solar flares
    let endTime: String?        // Solar flares
    let location: String?       // IPS: "Earth" etc.
    let catalog: String?
    let link: URL?
}

struct SpaceEventsView: View {
    @State private var events = [SpaceEvent]()
    @State private var isLoading = true
    @Environment(\.API_KEY) var api_key
    
    @State private var selectedCategory: String = "All"
    
    var availableCategories: [String] {
        ["All"] + Set(events.map { $0.type }).sorted()
    }
    
    var filteredEvents: [SpaceEvent] {
        events.filter { event in
            if selectedCategory == "All" {
                return true
            } else {
                return event.type == selectedCategory
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading space events...")
                } else if events.isEmpty {
                    ContentUnavailableView(
                        "No Events",
                        systemImage: "antenna.radiowaves.left.and.right",
                        description: Text("No space weather events in the past 7 days.")
                    )
                } else {
                    List(filteredEvents) { event in
                        NavigationLink(destination: SpaceEventDetailView(event: event)) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(event.type)
                                        .font(.headline)
                                    Spacer()
                                    if let cls = event.classType {
                                        Text(cls)
                                            .font(.caption.bold())
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(classTypeColor(cls).opacity(0.25))
                                            .foregroundStyle(classTypeColor(cls))
                                            .clipShape(Capsule())
                                    }
                                }
                                Text(event.date)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                if !event.detail.isEmpty {
                                    Text(event.detail)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color.black.opacity(0.5))
                    }
                }
            }
            .navigationTitle("Past Space Events")
            .defaultBackground(withStreaks: true)
            .scrollContentBackground(.hidden)
            .preferredColorScheme(.dark)
            .task {
                await loadAllEvents()
            }
            .toolbar {
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
        }
    }

    func classTypeColor(_ cls: String) -> Color {
        switch cls.prefix(1).uppercased() {
        case "X": return .red
        case "M": return .orange
        case "C": return .yellow
        default:  return .green
        }
    }

    func loadAllEvents() async {
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-604_800)
        let start = queryDateString(startDate)
        let end = queryDateString(endDate)
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

        events = allEvents.sorted { $0.rawDate > $1.rawDate }
        isLoading = false
    }

    func fetchEvents(type: String, from url: URL) async -> [SpaceEvent] {
        do {
            let data = try await NetworkService.fetch(from: url, as: [[String: AnyCodable]].self)

            return data.compactMap { dict -> SpaceEvent? in
                // Date — FLR uses beginTime; CME/GST use startTime; IPS/HSS use eventTime
                let startTime   = dict["startTime"]?.stringValue
                let beginTime   = dict["beginTime"]?.stringValue
                let eventTime   = dict["eventTime"]?.stringValue
                let time21_5    = dict["time21_5"]?.stringValue
                let rawDate     = startTime ?? beginTime ?? eventTime ?? time21_5 ?? ""

                // ID
                let activityID  = dict["activityID"]?.stringValue
                let gstID       = dict["gstID"]?.stringValue
                let sepID       = dict["sepID"]?.stringValue
                let mpcID       = dict["mpcID"]?.stringValue
                let rbeID       = dict["rbeID"]?.stringValue
                let hssID       = dict["hssID"]?.stringValue
                let flrID       = dict["flrID"]?.stringValue
                let id: String  = activityID ?? gstID ?? sepID ?? mpcID ?? rbeID ?? hssID ?? flrID ?? UUID().uuidString

                // Detail — use note only, skip "M2M_CATALOG" catalog fallback
                let noteRaw     = dict["note"]?.stringValue
                let detail      = (noteRaw?.isEmpty == false) ? (noteRaw ?? "") : ""

                // Extra fields
                let classRaw    = dict["classType"]?.stringValue
                let classType   = (classRaw?.isEmpty == false) ? classRaw : nil

                let locRaw      = dict["sourceLocation"]?.stringValue
                let sourceLocation = (locRaw?.isEmpty == false) ? locRaw : nil

                let peakRaw     = dict["peakTime"]?.stringValue
                let peakTime    = peakRaw.map { formatEventDate($0) }

                let endRaw      = dict["endTime"]?.stringValue
                let endTime     = endRaw.map { formatEventDate($0) }

                let locationRaw = dict["location"]?.stringValue
                let location    = (locationRaw?.isEmpty == false) ? locationRaw : nil

                let catalog     = dict["catalog"]?.stringValue
                let linkString  = dict["link"]?.stringValue
                let link        = linkString.flatMap { URL(string: $0) }

                return SpaceEvent(
                    id: id,
                    type: type,
                    date: formatEventDate(rawDate),
                    rawDate: rawDate,
                    detail: detail,
                    classType: classType,
                    sourceLocation: sourceLocation,
                    peakTime: peakTime,
                    endTime: endTime,
                    location: location,
                    catalog: catalog,
                    link: link
                )
            }
        } catch {
            print("Failed to load \(type):", error)
            return []
        }
    }

    func formatEventDate(_ rawDate: String) -> String {
        guard !rawDate.isEmpty else { return "Unknown date" }

        var fixed = rawDate

        // DONKI sometimes omits seconds (HH:mmZ)
        if fixed.range(of: #"T\d{2}:\d{2}Z"#, options: .regularExpression) != nil {
            fixed = fixed.replacingOccurrences(of: "Z", with: ":00Z")
        }

        let iso = ISO8601DateFormatter()

        if let date = iso.date(from: fixed) {
            return displayFormatter.string(from: date)
        }

        if let date = donkiFormatter.date(from: rawDate) {
            return displayFormatter.string(from: date)
        }

        return rawDate
    }

    func queryDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

private let displayFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    f.timeStyle = .short
    return f
}()

private let donkiFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd HH:mm:ss"
    f.timeZone = TimeZone(identifier: "UTC")
    return f
}()

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
