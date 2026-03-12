//
//  EONETObjects.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 12/03/2026.
//

import Foundation
import MapKit

struct EONETResponse: Codable {
    let events: [EONETEvent]
}

struct EONETEvent: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let link: URL
    let categories: [EONETCategory]
    let sources: [EONETSource]
    let geometries: [EONETGeometry]
    let closed: Date?

    var category: String {
        categories.first?.title ?? "Unknown"
    }

    var latestGeometry: EONETGeometry? {
        geometries.last
    }

    var isClosed: Bool {
        closed != nil
    }
}

struct EONETCategory: Codable {
    let id: Int
    let title: String
}

struct EONETSource: Codable, Identifiable {
    let id: String
    let url: URL
}

// GeoJSON coordinates vary by geometry type:
//   Point   → [longitude, latitude]         i.e. [Double]
//   Polygon → [[[longitude, latitude], …]]  i.e. [[[Double]]]
// We use an enum to handle both.
enum EONETCoordinates: Codable {
    case point([Double])
    case polygon([[[Double]]])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let point = try? container.decode([Double].self) {
            self = .point(point)
        } else if let polygon = try? container.decode([[[Double]]].self) {
            self = .polygon(polygon)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode coordinates as Point or Polygon"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .point(let coords):    try container.encode(coords)
        case .polygon(let coords):  try container.encode(coords)
        }
    }
}

struct EONETGeometry: Codable {
    let date: Date
    let type: String
    let coordinates: EONETCoordinates

    // Convenience accessor for Point geometries
    var pointCoordinates: (longitude: Double, latitude: Double)? {
        guard case .point(let coords) = coordinates, coords.count >= 2 else { return nil }
        return (longitude: coords[0], latitude: coords[1])
    }
}

extension EONETEvent {

    var coordinate: CLLocationCoordinate2D? {
        guard let point = latestGeometry?.pointCoordinates else { return nil }

        return CLLocationCoordinate2D(
            latitude: point.latitude,
            longitude: point.longitude
        )
    }
}
