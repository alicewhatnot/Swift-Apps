//
//  User.swift
//  FriendFace
//
//  Created by Michael Gillbanks on 20/02/2026.
//

import SwiftData
import Foundation

@Model
class User: Codable, Hashable {
    enum CodingKeys: CodingKey {
        case id
        case isActive
        case name
        case age
        case company
        case address
        case about
        case registered
        case tags
        case friends
    }
    
    var id: UUID
    var isActive: Bool
    var name: String
    var age: Int
    var company: String
    var address: String
    var about: String
    var registered: Date
    var tags: [String]
    var friends: [Friend]
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let stringId = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: stringId) ?? UUID()

        self.isActive = try container.decode(Bool.self, forKey: .isActive)
        self.name = try container.decode(String.self, forKey: .name)
        self.age = try container.decode(Int.self, forKey: .age)
        self.company = try container.decode(String.self, forKey: .company)
        self.address = try container.decode(String.self, forKey: .address)
        self.about = try container.decode(String.self, forKey: .about)
        self.registered = try container.decode(Date.self, forKey: .registered)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.friends = try container.decode([Friend].self, forKey: .friends)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.id.uuidString, forKey: .id)
        try container.encode(self.isActive, forKey: .isActive)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.age, forKey: .age)
        try container.encode(self.company, forKey: .company)
        try container.encode(self.address, forKey: .address)
        try container.encode(self.about, forKey: .about)

        let formatter = ISO8601DateFormatter()
        let stringDate = formatter.string(from: self.registered)
        try container.encode(stringDate, forKey: .registered)

        try container.encode(self.tags, forKey: .tags)
        try container.encode(self.friends, forKey: .friends)
    }
}

@Model
class Friend: Codable, Hashable {
    enum CodingKeys: CodingKey {
        case id
        case name
    }
    
    var id: UUID
    var name: String
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let stringId = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: stringId) ?? UUID()
        self.name = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id.uuidString, forKey: .id)
        try container.encode(self.name, forKey: .name)
    }
    
}
