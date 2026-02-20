//
//  User.swift
//  FriendFace
//
//  Created by Michael Gillbanks on 20/02/2026.
//

import Foundation

struct User: Codable, Hashable {
    let id: UUID
    var isActive: Bool
    var name: String
    var age: Int
    var company: String
    var address: String
    var about: String
    var registered: Date
    var tags: [String]
    var friends: [Friend]

}

struct Friend: Codable, Hashable {
    let id: UUID
    var name: String
}
