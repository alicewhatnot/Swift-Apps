//
//  NearEarthObjects.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 08/03/2026.
//

import Foundation

struct NEOFeed: Codable {
    let element_count: Int
    let near_earth_objects: [String: [NearEarthObject]]

    func allAsteroids(filterHazardous: Bool) -> [NearEarthObject] {
        let objects = near_earth_objects.values.flatMap { $0 }

        let futureObjects = objects.filter {
            guard let firstDate = $0.close_approach_data.first?.approachDate else { return false }
            return firstDate > Date()
        }

        let filtered = filterHazardous
            ? futureObjects.filter { $0.is_potentially_hazardous_asteroid }
            : futureObjects

        // Deduplicate by first approach date rounded to the minute
        var seenDates = Set<Date>()
        let uniqueByDate = filtered.compactMap { neo -> NearEarthObject? in
            guard let firstDate = neo.close_approach_data.first?.approachDateRoundedToMinute else {
                return nil
            }
            if seenDates.contains(firstDate) {
                return nil
            } else {
                seenDates.insert(firstDate)
                return neo
            }
        }

        return uniqueByDate.sorted()
    }
}

struct NearEarthObject: Codable, Identifiable, Comparable {
    let id: String
    let name: String
    let absolute_magnitude_h: Double
    let estimated_diameter: EstimatedDiameter
    let is_potentially_hazardous_asteroid: Bool
    let close_approach_data: [CloseApproach]
    
    let orbital_data: OrbitalData?
    
    var diameterKM: Double {
        (estimated_diameter.kilometers.estimated_diameter_min +
         estimated_diameter.kilometers.estimated_diameter_max) / 2
    }
    
    static func < (lhs: NearEarthObject, rhs: NearEarthObject) -> Bool {
        let lhsDate = lhs.close_approach_data.first?.approachDate ?? .distantFuture
        let rhsDate = rhs.close_approach_data.first?.approachDate ?? .distantFuture
        return lhsDate < rhsDate
    }
    
    static func == (lhs: NearEarthObject, rhs: NearEarthObject) -> Bool {
        lhs.id == rhs.id
    }
}

struct EstimatedDiameter: Codable {
    let kilometers: DiameterRange
}

struct DiameterRange: Codable {
    let estimated_diameter_min: Double
    let estimated_diameter_max: Double
}

struct CloseApproach: Codable {
    let close_approach_date: String
    let close_approach_date_full: String?
    let epoch_date_close_approach: Int
    let relative_velocity: RelativeVelocity
    let miss_distance: MissDistance
    let orbiting_body: String
    
    var velocityKMPerSecond: Double? {
        Double(relative_velocity.kilometers_per_second)?.rounded()
    }
    
    var missDistanceKM: Double? {
        Double(miss_distance.kilometers)
    }
    
    private static let fullInputFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MMM-dd HH:mm"
        return f
    }()

    private static let dateInputFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let outputFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM HH:mm"
        return f
    }()

    func formattedApproachDate() -> String {
        let date =
            (close_approach_date_full.flatMap { Self.fullInputFormatter.date(from: $0) }) ??
            Self.dateInputFormatter.date(from: close_approach_date)

        guard let date else {
            return close_approach_date
        }

        return Self.outputFormatter.string(from: date)
    }
    
    var timeToApproach: String? {
        let date =
            (close_approach_date_full.flatMap { Self.fullInputFormatter.date(from: $0) }) ??
            Self.dateInputFormatter.date(from: close_approach_date)

        guard let date else { return nil }

        let interval = date.timeIntervalSinceNow
        guard interval > 0 else { return "Already passed" }

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2

        return formatter.string(from: interval)
    }
    
    var approachDate: Date? {
        if let full = close_approach_date_full,
           let date = Self.fullInputFormatter.date(from: full) {
            return date
        }
        return Self.dateInputFormatter.date(from: close_approach_date)
    }
    
    var approachDateRoundedToMinute: Date? {
        guard let date = approachDate else { return nil }
        let calendar = Calendar.current
        return calendar.date(bySetting: .second, value: 0, of: date)
    }
}

struct RelativeVelocity: Codable {
    let kilometers_per_second: String
}

struct MissDistance: Codable {
    let astronomical: String
    let kilometers: String
}

struct OrbitalData: Codable {
    let first_observation_date: String?
}
