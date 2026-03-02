//
//  Card.swift
//  Flashzilla
//
//  Created by Michael Gillbanks on 01/03/2026.
//

import Foundation

struct Card: Codable, Identifiable {
    var id: UUID
    var prompt: String
    var answer: String
    
    static let example = Card(prompt: "Who played the 13th Doctor in Doctor Who?", answer: "Jodie Whittaker")
    
    init(prompt: String, answer: String) {
        self.id = UUID()
        self.prompt = prompt
        self.answer = answer
    }
}
