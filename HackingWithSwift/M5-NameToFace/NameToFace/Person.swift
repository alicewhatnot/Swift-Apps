//
//  People.swift
//  NameToFace
//
//  Created by Michael Gillbanks on 25/02/2026.
//

import Foundation
import SwiftData
import UIKit

@Model
class Person: Identifiable {
    @Attribute(.externalStorage) var photo: Data
    var name: String
    var notes: String
    var latitude: Double?
    var longitude: Double?
        
    init(photo: Data, name: String, notes: String, latitude: Double?, longitude: Double?) {
        self.photo = photo
        self.name = name
        self.notes = notes
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension Person {
    var uiImage: UIImage? {
        UIImage(data: photo)
    }
}
