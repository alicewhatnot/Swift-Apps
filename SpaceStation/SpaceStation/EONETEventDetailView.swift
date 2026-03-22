//
//  EONETEventDetailView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 14/03/2026.
//

import SwiftUI
import MapKit

struct EONETEventDetailView: View {
    let event: EONETEvent
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Header card
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.title2.bold())
                            Text(event.category)
                                .font(.subheadline)
                                .foregroundStyle(.primary.opacity(0.75))
                        }
                        Spacer()
                        StatusBadge(isClosed: event.isClosed)
                    }

                    if let geometry = event.latestGeometry {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .accessibilityHidden(true)
                            Text("Last updated \(geometry.date.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                        }
                        .foregroundStyle(.primary.opacity(0.75))
                    }
                }
                .padding()
                .background(.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(headerAccessibilityLabel)

                // Map
                if let coordinate = event.coordinate {
                    SectionCard(title: "Location", systemImage: "map") {
                        Map(initialPosition: .region(MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 8, longitudeDelta: 8)
                        ))) {
                            Marker(event.title, coordinate: coordinate)
                                .tint(categoryColor(event.category))
                        }
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityLabel("Map showing location of \(event.title)")
                        .accessibilityHint("Interactive map")

                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .font(.caption)
                                .accessibilityHidden(true)
                            Text(String(format: "%.4f°, %.4f°",
                                        coordinate.latitude,
                                        coordinate.longitude))
                                .font(.caption.monospacedDigit())
                        }
                        .foregroundStyle(.primary.opacity(0.75))
                        .padding(.top, 4)
                        .accessibilityLabel(String(format: "Coordinates: %.4f degrees latitude, %.4f degrees longitude",
                                                   coordinate.latitude, coordinate.longitude))
                    }
                }

                // Description
                if let description = event.description, !description.isEmpty {
                    SectionCard(title: "Description", systemImage: "doc.text") {
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.primary.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Description: \(description)")
                }

                // Geometry history
                if event.geometries.count > 1 {
                    SectionCard(title: "Track (\(event.geometries.count) points)", systemImage: "waveform.path") {
                        VStack(spacing: 8) {
                            ForEach(Array(event.geometries.reversed().prefix(10).enumerated()), id: \.offset) { index, geometry in
                                HStack(alignment: .top) {
                                    Circle()
                                        .fill(index == 0 ? categoryColor(event.category) : .secondary.opacity(0.4))
                                        .frame(width: 8, height: 8)
                                        .padding(.top, 5)
                                        .accessibilityHidden(true)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(geometry.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.primary.opacity(0.75))

                                        if let coords = geometry.pointCoordinates {
                                            Text(String(format: "%.4f°, %.4f°",
                                                        coords.latitude,
                                                        coords.longitude))
                                                .font(.caption.monospacedDigit())
                                                .foregroundStyle(.primary.opacity(0.6))
                                        }
                                    }
                                    Spacer()
                                }
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel({
                                    var label = index == 0 ? "Most recent: " : ""
                                    label += geometry.date.formatted(date: .abbreviated, time: .shortened)
                                    if let coords = geometry.pointCoordinates {
                                        label += String(format: ", %.4f degrees latitude, %.4f degrees longitude",
                                                        coords.latitude, coords.longitude)
                                    }
                                    return label
                                }())
                            }

                            if event.geometries.count > 10 {
                                Text("+ \(event.geometries.count - 10) more observations")
                                    .font(.caption)
                                    .foregroundStyle(.primary.opacity(0.5))
                                    .accessibilityLabel("\(event.geometries.count - 10) more observations not shown")
                            }
                        }
                    }
                }

                // Sources
                if !event.sources.isEmpty {
                    SectionCard(title: "Sources", systemImage: "link") {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(event.sources) { source in
                                Link(destination: source.url) {
                                    HStack {
                                        Text(source.id)
                                            .font(.subheadline.bold())
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption)
                                            .accessibilityHidden(true)
                                    }
                                    .foregroundStyle(.blue)
                                }
                                .accessibilityLabel("View source: \(source.id)")
                                .accessibilityHint("Opens in browser")
                                .accessibilityAddTraits(.isLink)
                            }
                        }
                    }
                }

                // EONET page link
                SectionCard(title: "EONET", systemImage: "globe") {
                    Link(destination: event.link) {
                        HStack {
                            Text("View on NASA EONET")
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .accessibilityHidden(true)
                        }
                        .foregroundStyle(.blue)
                    }
                    .accessibilityLabel("View on NASA EONET")
                    .accessibilityHint("Opens in browser")
                    .accessibilityAddTraits(.isLink)
                }
            }
            .padding()
        }
        .navigationTitle(event.category)
        .navigationBarTitleDisplayMode(.inline)
        .defaultBackground(reduceMotion: reduceMotion)
        .preferredColorScheme(.dark)
    }

    // MARK: - Accessibility label helpers

    var headerAccessibilityLabel: String {
        var parts = [event.title, event.category]
        parts.append(event.isClosed ? "closed" : "active")
        if let geometry = event.latestGeometry {
            parts.append("last updated \(geometry.date.formatted(date: .abbreviated, time: .shortened))")
        }
        return parts.joined(separator: ", ")
    }

    func categoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case let c where c.contains("wildfire"), let c where c.contains("fire"):   return .orange
        case let c where c.contains("storm"), let c where c.contains("cyclone"):   return .blue
        case let c where c.contains("flood"):                                       return .cyan
        case let c where c.contains("volcano"):                                     return .red
        case let c where c.contains("earthquake"):                                  return .brown
        case let c where c.contains("drought"):                                     return .yellow
        case let c where c.contains("ice"), let c where c.contains("snow"):        return .white
        default:                                                                     return .green
        }
    }
}

// MARK: - Status badge

struct StatusBadge: View {
    let isClosed: Bool

    var body: some View {
        Text(isClosed ? "Closed" : "Active")
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(isClosed ? Color.red.opacity(0.25) : Color.green.opacity(0.25))
            .foregroundStyle(isClosed ? .red : .green)
            .clipShape(Capsule())
            .accessibilityHidden(true) // spoken as part of header combined label
    }
}

#Preview {
    NavigationStack {
        EONETEventDetailView(event: EONETEvent(
            id: "EONET_5765",
            title: "Tropical Storm Unittest",
            description: "A sample tropical storm for preview purposes.",
            link: URL(string: "https://eonet.gsfc.nasa.gov/api/v2.1/events/EONET_5765")!,
            categories: [EONETCategory(id: 10, title: "Severe Storms")],
            sources: [EONETSource(id: "GDACS", url: URL(string: "https://www.gdacs.org")!)],
            geometries: [],
            closed: nil
        ))
    }
}
