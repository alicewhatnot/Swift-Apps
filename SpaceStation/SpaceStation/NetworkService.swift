//
//  NetworkService.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 08/03/2026.
//

import Foundation

struct NetworkService {
    static func fetch<T: Decodable>(
        from url: URL,
        as type: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let (data, _) = try await URLSession.shared.data(from: url)
        return try decoder.decode(T.self, from: data)
    }
}
