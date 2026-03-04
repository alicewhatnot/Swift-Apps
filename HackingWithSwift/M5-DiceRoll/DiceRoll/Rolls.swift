//
//  Rolls.swift
//  DiceRoll
//
//  Created by Michael Gillbanks on 04/03/2026.
//

import Foundation
import SwiftData

@Model
class Roll: Identifiable {
    var id: UUID
    var date: Date
    var number: Int
    
    var formattedDate: String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
    
    init(_ number: Int) {
        self.id = UUID()
        self.date = Date.now
        self.number = number
    }
}

