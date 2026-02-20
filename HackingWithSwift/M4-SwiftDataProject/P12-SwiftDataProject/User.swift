//
//  User.swift
//  M4-SwiftDataProject
//
//  Created by Michael Gillbanks on 19/02/2026.
//

import Foundation
import SwiftData

@Model
class User {
    var name: String
    var city: String
    var joinDate: Date
    @Relationship(deleteRule: .cascade) var jobs = [Job]()
    
    init(name: String, city: String, joinDate: Date) {
        self.name = name
        self.city = city
        self.joinDate = joinDate
    }
}

let str = """
    {
        "first": "Andrew",
        "last": "Glouberman",
        "age": "13"
    }
    """

struct Test: Codable {
    enum CodingKeys: String, CodingKey {
        case firstName = "first"
        case lastName = "last"
        case age
    }
    
    var firstName: String
    var lastName: String
    var age: Int
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        var stringAge = try container.decode(String.self, forKey: .age)
        self.age = Int(stringAge) ?? 0
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.firstName, forKey: .firstName)
        try container.encode(self.lastName, forKey: .lastName)
        try container.encode(String(self.age), forKey: .age)
    }
}
    
