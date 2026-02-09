//
//  Habit.swift
//  M3-HabitTrack
//
//  Created by Michael Gillbanks on 09/02/2026.
//

import Foundation

@Observable
class Habits {
    var items: [Habit] = []
}

struct Habit: Identifiable, Codable {
    struct HabitEvent: Identifiable, Codable {
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

