//
//  SpaceEventsView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 11/03/2026.
//

import SwiftUI
import SwiftData

struct SpaceEvent: Identifiable {
    let id: String
    let type: String
    let date: String
    let rawDate: String
    let detail: String
    let classType: String?
    let sourceLocation: String?
    let peakTime: String?
    let endTime: String?
    let location: String?
    let catalog: String?
    let link: URL?
}

struct SpaceEventsView: View {
    @Environment(\.API_KEY) var api_key
    @Environment(\.modelContext) var modelContext
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Query private var cachedEvents: [CachedSpaceEvents]

    @State private var events = [SpaceEvent]()
    @State private var isLoading = true
    @State private var selectedType: String = "All"

    var availableTypes: [String] {
        ["All"] + Set(events.map { $0.type }).sorted()
    }

    var filteredEvents: [SpaceEvent] {
        events.filter { selectedType == "All" || $0.type == selectedType }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading space events...")
                } else if filteredEvents.isEmpty {
                    ContentUnavailableView(
                        "No Events",
                        systemImage: "antenna.radiowaves.left.and.right",
                        description: Text(selectedType == "All"
                            ? "No space weather events in the past 7 days."
                            : "No \(selectedType) events in the past 7 days.")
                    )
                } else {
                    List(filteredEvents) { event in
                        NavigationLink(destination: SpaceEventDetailView(event: event)) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(event.type).font(.headline)
                                    Spacer()
                                    if let cls = event.classType {
                                        Text(cls)
                                            .font(.caption.bold())
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(classTypeColor(cls).opacity(0.25))
                                            .foregroundStyle(classTypeColor(cls))
                                            .clipShape(Capsule())
                                            .accessibilityLabel("Class \(cls)")
                                    }
                                }
                                Text(event.date)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary.opacity(0.75))
                                if let loc = event.sourceLocation {
                                    Text(loc)
                                        .font(.caption)
                                        .foregroundStyle(.primary.opacity(0.6))
                                }
                                if !event.detail.isEmpty {
                                    Text(event.detail)
                                        .font(.caption)
                                        .foregroundStyle(.primary.opacity(0.75))
                                        .lineLimit(2)
                                }
                            }
                            .padding(.vertical, 4)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(accessibilityLabel(for: event))
                        }
                        .listRowBackground(Color.black.opacity(0.5))
                    }
                }
            }
            .navigationTitle("Space Events")
            .defaultBackground(reduceMotion: reduceMotion)
            .scrollContentBackground(.hidden)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem {
                    Menu {
                        ForEach(availableTypes, id: \.self) { type in
                            Button(type) { selectedType = type }
                        }
                    } label: {
                        Text("Filter")
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                    .accessibilityLabel("Filter by event type")
                    .accessibilityHint("Currently showing: \(selectedType)")
                }
            }
            .task { await loadEvents() }
            .refreshable { await refreshFromNetwork() }
        }
    }

    func accessibilityLabel(for event: SpaceEvent) -> String {
        var parts = [event.type]
        if let cls = event.classType { parts.append("class \(cls)") }
        parts.append(event.date)
        if let loc = event.sourceLocation { parts.append("source: \(loc)") }
        if !event.detail.isEmpty { parts.append(event.detail) }
        return parts.joined(separator: ", ")
    }

    func classTypeColor(_ cls: String) -> Color {
        switch cls.prefix(1).uppercased() {
        case "X": return .red
        case "M": return .orange
        case "C": return .yellow
        default:  return .green
        }
    }

    func loadEvents() async {
        if let cached = cachedEvents.first, !cached.isStale,
           let serialized = try? JSONDecoder().decode([SerializableSpaceEvent].self, from: cached.jsonData) {
            events = serialized.map { $0.toSpaceEvent(formatDate: formatEventDate) }
            isLoading = false
        } else {
            await refreshFromNetwork()
        }
    }

    func refreshFromNetwork() async {
        do {
            let serialized = try await CacheService.fetchAndCacheSpaceEvents(
                apiKey: api_key,
                context: modelContext
            )
            events = serialized.map { $0.toSpaceEvent(formatDate: formatEventDate) }
        } catch {
            print("Failed to load space events:", error)
        }
        isLoading = false
    }

    func formatEventDate(_ rawDate: String) -> String {
        guard !rawDate.isEmpty else { return "Unknown date" }
        var fixed = rawDate
        if fixed.range(of: #"T\d{2}:\d{2}Z"#, options: .regularExpression) != nil {
            fixed = fixed.replacingOccurrences(of: "Z", with: ":00Z")
        }
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: fixed) { return displayFormatter.string(from: date) }
        if let date = donkiFormatter.date(from: rawDate) { return displayFormatter.string(from: date) }
        return rawDate
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
