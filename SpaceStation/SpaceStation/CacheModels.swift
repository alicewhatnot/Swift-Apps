//
//  CacheModels.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 14/03/2026.
//

import Foundation
import SwiftData

// MARK: - NEO Cache

@Model
class CachedNEOFeed {
    var jsonData: Data
    var fetchedAt: Date

    init(jsonData: Data, fetchedAt: Date = .now) {
        self.jsonData = jsonData
        self.fetchedAt = fetchedAt
    }

    var isStale: Bool {
        Date.now.timeIntervalSince(fetchedAt) > 60 * 60 * 2 // 2 hours
    }
}

// MARK: - EONET Cache

@Model
class CachedEONETFeed {
    var jsonData: Data
    var fetchedAt: Date

    init(jsonData: Data, fetchedAt: Date = .now) {
        self.jsonData = jsonData
        self.fetchedAt = fetchedAt
    }

    var isStale: Bool {
        Date.now.timeIntervalSince(fetchedAt) > 60 * 60 // 1 hour
    }
}

// MARK: - APOD Cache

@Model
class CachedAPOD {
    var jsonData: Data
    var fetchedAt: Date
    var apodDate: String // "yyyy-MM-dd" — APOD is keyed by date

    init(jsonData: Data, apodDate: String, fetchedAt: Date = .now) {
        self.jsonData = jsonData
        self.apodDate = apodDate
        self.fetchedAt = fetchedAt
    }

    var isStale: Bool {
        Date.now.timeIntervalSince(fetchedAt) > 60 * 60 // 1 hour
    }
}

// MARK: - Space Events Cache

@Model
class CachedSpaceEvents {
    var jsonData: Data
    var fetchedAt: Date

    init(jsonData: Data, fetchedAt: Date = .now) {
        self.jsonData = jsonData
        self.fetchedAt = fetchedAt
    }

    var isStale: Bool {
        Date.now.timeIntervalSince(fetchedAt) > 60 * 30 // 30 minutes
    }
}

// MARK: - Serializable SpaceEvent (for caching)
// SpaceEvent uses non-Codable types so we store a stripped version.

struct SerializableSpaceEvent: Codable {
    let id: String
    let type: String
    let rawDate: String
    let detail: String
    let classType: String?
    let sourceLocation: String?
    let peakTime: String?
    let endTime: String?
    let location: String?
    let catalog: String?
    let linkString: String?

    func toSpaceEvent(formatDate: (String) -> String) -> SpaceEvent {
        SpaceEvent(
            id: id,
            type: type,
            date: formatDate(rawDate),
            rawDate: rawDate,
            detail: detail,
            classType: classType,
            sourceLocation: sourceLocation,
            peakTime: peakTime.map { formatDate($0) },
            endTime: endTime.map { formatDate($0) },
            location: location,
            catalog: catalog,
            link: linkString.flatMap { URL(string: $0) }
        )
    }
}

// MARK: - Seen Asteroid IDs (for notification diffing)

@Model
class SeenAsteroidIDs {
    var ids: [String]
    var updatedAt: Date

    init(ids: [String] = [], updatedAt: Date = .now) {
        self.ids = ids
        self.updatedAt = updatedAt
    }
}
