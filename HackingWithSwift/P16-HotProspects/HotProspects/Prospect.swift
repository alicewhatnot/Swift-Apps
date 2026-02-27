//
//  Prospect.swift
//  HotProspects
//
//  Created by Michael Gillbanks on 27/02/2026.
//

import SwiftData
import SwiftUI

@Model
class Prospect {
    var name: String
    var emailAddress: String
    var isContacted: Bool
    var dateAdded: Date
    
    init(name: String, emailAddress: String, isContacted: Bool, dateAdded: Date = .now) {
        self.name = name
        self.emailAddress = emailAddress
        self.isContacted = isContacted
        self.dateAdded = dateAdded
    }
}
