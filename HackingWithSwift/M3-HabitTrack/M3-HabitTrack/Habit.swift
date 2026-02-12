//
//  Habit.swift
//  M3-HabitTrack
//
//  Created by Michael Gillbanks on 09/02/2026.
//

import Foundation

@Observable
class Habits: Codable {

    var items: [Habit]

    init(items: [Habit] = []) {
        self.items = items
    }

    // MARK: - Codable

    enum CodingKeys: CodingKey {
        case items
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decode([Habit].self, forKey: .items)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(items, forKey: .items)
    }
}


struct Habit: Identifiable, Codable, Equatable {
    struct HabitEvent: Identifiable, Codable, Equatable {
        var id: UUID = UUID()
        var description: String
        var date: Date
        var formattedDate: String {
            date.formatted(date: .abbreviated, time: .shortened)
        }
    }

    var id = UUID()
    var name: String
    var description: String
    var events: [HabitEvent]
}

extension Habits {
    
    private static var saveURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("habits.json")
    }
    
    func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        if let data = try? encoder.encode(self) {
            try? data.write(to: Self.saveURL, options: [.atomic])
        }
    }
    
    static func load() -> Habits {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let data = try? Data(contentsOf: saveURL),
              let habits = try? decoder.decode(Habits.self, from: data)
        else {
            return Habits()
        }
        
        return habits
    }
}


