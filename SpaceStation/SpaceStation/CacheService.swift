//
//  CacheService.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 15/03/2026.
//

import Foundation
import SwiftData

/// Helpers for fetching from the network and saving raw JSON into SwiftData cache models.
struct CacheService {

    // MARK: - NEO

    /// Fetches a fresh NEO feed from the API, saves it to SwiftData, and returns the decoded result.
    @MainActor
    static func fetchAndCacheNEOs(
        apiKey: String,
        context: ModelContext
    ) async throws -> NEOFeed {
        guard let url = URL(string: "https://api.nasa.gov/neo/rest/v1/feed?api_key=\(apiKey)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)

        let feed = try JSONDecoder().decode(NEOFeed.self, from: data)

        // Delete any existing cache entry and replace
        try context.delete(model: CachedNEOFeed.self)
        context.insert(CachedNEOFeed(jsonData: data))
        try context.save()

        return feed
    }

    // MARK: - EONET

    @MainActor
    static func fetchAndCacheEONET(
        context: ModelContext
    ) async throws -> EONETResponse {
        guard let url = URL(string: "https://eonet.gsfc.nasa.gov/api/v2.1/events?days=30") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(EONETResponse.self, from: data)

        try context.delete(model: CachedEONETFeed.self)
        context.insert(CachedEONETFeed(jsonData: data))
        try context.save()

        return response
    }

    // MARK: - APOD

    @MainActor
    static func fetchAndCacheAPOD(
        apiKey: String,
        context: ModelContext
    ) async throws -> APOD {
        guard let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=\(apiKey)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let apod = try JSONDecoder().decode(APOD.self, from: data)

        let todayString = {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            return f.string(from: .now)
        }()

        try context.delete(model: CachedAPOD.self)
        context.insert(CachedAPOD(jsonData: data, apodDate: todayString))
        try context.save()

        return apod
    }

    // MARK: - Space Events

    @MainActor
    static func fetchAndCacheSpaceEvents(
        apiKey: String,
        context: ModelContext
    ) async throws -> [SerializableSpaceEvent] {
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-604_800)
        let start = isoDateString(startDate)
        let end   = isoDateString(endDate)

        let endpoints: [(String, String)] = [
            ("Coronal Mass Ejection",       "https://api.nasa.gov/DONKI/CME?startDate=\(start)&endDate=\(end)&api_key=\(apiKey)"),
            ("Geomagnetic Storm",           "https://api.nasa.gov/DONKI/GST?startDate=\(start)&endDate=\(end)&api_key=\(apiKey)"),
            ("Interplanetary Shock",        "https://api.nasa.gov/DONKI/IPS?startDate=\(start)&endDate=\(end)&catalog=ALL&api_key=\(apiKey)"),
            ("Solar Flare",                 "https://api.nasa.gov/DONKI/FLR?startDate=\(start)&endDate=\(end)&api_key=\(apiKey)"),
            ("Solar Energetic Particle",    "https://api.nasa.gov/DONKI/SEP?startDate=\(start)&endDate=\(end)&api_key=\(apiKey)"),
            ("Magnetopause Crossing",       "https://api.nasa.gov/DONKI/MPC?startDate=\(start)&endDate=\(end)&api_key=\(apiKey)"),
            ("Radiation Belt Enhancement",  "https://api.nasa.gov/DONKI/RBE?startDate=\(start)&endDate=\(end)&api_key=\(apiKey)"),
            ("High Speed Stream",           "https://api.nasa.gov/DONKI/HSS?startDate=\(start)&endDate=\(end)&api_key=\(apiKey)")
        ]

        var allEvents = [SerializableSpaceEvent]()

        await withTaskGroup(of: [SerializableSpaceEvent].self) { group in
            for (type, urlString) in endpoints {
                guard let url = URL(string: urlString) else { continue }
                group.addTask {
                    await fetchDONKIEndpoint(type: type, from: url)
                }
            }
            for await result in group {
                allEvents.append(contentsOf: result)
            }
        }

        let sorted = allEvents.sorted { $0.rawDate > $1.rawDate }
        let data = try JSONEncoder().encode(sorted)

        try context.delete(model: CachedSpaceEvents.self)
        context.insert(CachedSpaceEvents(jsonData: data))
        try context.save()

        return sorted
    }

    // MARK: - Private helpers

    private static func fetchDONKIEndpoint(
        type: String,
        from url: URL
    ) async -> [SerializableSpaceEvent] {
        do {
            let data = try await NetworkService.fetch(from: url, as: [[String: AnyCodable]].self)
            print(data)
            return data.compactMap { dict -> SerializableSpaceEvent? in
                let startTime  = dict["startTime"]?.stringValue
                let beginTime  = dict["beginTime"]?.stringValue
                let eventTime  = dict["eventTime"]?.stringValue
                let time21_5   = dict["time21_5"]?.stringValue
                let rawDate    = startTime ?? beginTime ?? eventTime ?? time21_5 ?? ""

                let activityID = dict["activityID"]?.stringValue
                let gstID      = dict["gstID"]?.stringValue
                let sepID      = dict["sepID"]?.stringValue
                let mpcID      = dict["mpcID"]?.stringValue
                let rbeID      = dict["rbeID"]?.stringValue
                let hssID      = dict["hssID"]?.stringValue
                let flrID      = dict["flrID"]?.stringValue
                let id         = activityID ?? gstID ?? sepID ?? mpcID ?? rbeID ?? hssID ?? flrID ?? UUID().uuidString

                let noteRaw    = dict["note"]?.stringValue
                let detail     = (noteRaw?.isEmpty == false) ? (noteRaw ?? "") : ""

                let classRaw   = dict["classType"]?.stringValue
                let locRaw     = dict["sourceLocation"]?.stringValue

                return SerializableSpaceEvent(
                    id: id,
                    type: type,
                    rawDate: rawDate,
                    detail: detail,
                    classType: (classRaw?.isEmpty == false) ? classRaw : nil,
                    sourceLocation: (locRaw?.isEmpty == false) ? locRaw : nil,
                    peakTime: dict["peakTime"]?.stringValue,
                    endTime: dict["endTime"]?.stringValue,
                    location: dict["location"]?.stringValue,
                    catalog: dict["catalog"]?.stringValue,
                    linkString: dict["link"]?.stringValue
                )
            }
        } catch {
            print("Failed to load \(type):", error)
            return []
        }
    }

    private static func isoDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
