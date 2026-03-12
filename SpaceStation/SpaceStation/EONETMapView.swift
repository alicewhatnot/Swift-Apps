//
//  EONETMapView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 12/03/2026.
//

import SwiftUI
import MapKit

struct EONETMapView: View {

    let events: [EONETEvent]

    @State private var cameraPosition: MapCameraPosition =
        .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 120)
            )
        )
    @State private var selectedEvent: EONETEvent?

    private let clusterRadius: Double = 4

    var clusteredEvents: [EONETEvent] {
        var remaining = events.compactMap { event -> (EONETEvent, CLLocationCoordinate2D)? in
            guard let coord = event.coordinate else { return nil }
            return (event, coord)
        }
        var representatives: [EONETEvent] = []

        while !remaining.isEmpty {
            let (rep, repCoord) = remaining.removeFirst()
            remaining.removeAll { (_, coord) in
                abs(coord.latitude  - repCoord.latitude)  < clusterRadius &&
                abs(coord.longitude - repCoord.longitude) < clusterRadius
            }
            representatives.append(rep)
        }

        return representatives
    }

    var body: some View {

        Map(position: $cameraPosition) {

            ForEach(clusteredEvents) { event in

                let style = style(for: event.category)

                Annotation(event.title, coordinate: event.coordinate!) {
                    Image(systemName: style.icon)
                        .foregroundStyle(style.color)
                        .font(.title3)
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .onTapGesture {
                            selectedEvent = event
                        }
                        .popover(isPresented: Binding(
                            get: { selectedEvent?.id == event.id },
                            set: { if !$0 { selectedEvent = nil } }
                        )) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                    .font(.headline)
                                if let date = event.latestGeometry?.date {
                                    Text(date, style: .date)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .presentationCompactAdaptation(.popover)
                        }
                }
                .annotationTitles(.hidden)
            }
        }
        .navigationTitle("Event Map")
        .navigationBarTitleDisplayMode(.inline)
    }

    func style(for category: String) -> (icon: String, color: Color) {
        switch category {
        case "Wildfires":        return ("flame.fill", .red)
        case "Volcanoes":        return ("mountain.2.fill", .brown)
        case "Severe Storms":    return ("hurricane", .purple)
        case "Floods":           return ("drop.fill", .blue)
        case "Sea and Lake Ice": return ("snowflake", .cyan)
        case "Dust and Haze":    return ("wind", .gray)
        case "Drought":          return ("sun.max.fill", .yellow)
        case "Landslides":       return ("triangle.fill", .orange)
        default:                 return ("globe", .white)
        }
    }
}
