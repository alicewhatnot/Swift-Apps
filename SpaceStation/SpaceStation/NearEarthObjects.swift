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
}

struct NearEarthObject: Codable, Identifiable {
    let id: String
    let name: String
    let absolute_magnitude_h: Double
    let estimated_diameter: EstimatedDiameter
    let is_potentially_hazardous_asteroid: Bool
    let close_approach_data: [CloseApproach]
    
    // Not present in feed endpoint, but exists in the detailed object endpoint
    let orbital_data: OrbitalData?
    
    var diameterKM: Double {
        (estimated_diameter.kilometers.estimated_diameter_min +
         estimated_diameter.kilometers.estimated_diameter_max) / 2
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
        Double(relative_velocity.kilometers_per_second)
    }
    
    var missDistanceKM: Double? {
        Double(miss_distance.kilometers)
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
