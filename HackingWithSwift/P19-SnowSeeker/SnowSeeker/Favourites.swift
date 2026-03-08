//
//  Favourites.swift
//  SnowSeeker
//
//  Created by Michael Gillbanks on 06/03/2026.
//

import SwiftUI

@Observable
class Favourites {
    private var resorts: Set<String>
    private let key = "Favourites"
    
    init() {
        if let savedResorts = UserDefaults.standard.data(forKey: key) {
            if let decodedResorts = try? JSONDecoder().decode(Set<String>.self, from: savedResorts) {
                resorts = decodedResorts
                return
            }
        }
        resorts = []
    }
    
    func contains(_ resort: Resort) -> Bool {
        resorts.contains(resort.id)
    }
    
    func add(_ resort: Resort) {
        resorts.insert(resort.id)
        save()
    }
    
    func remove(_ resort: Resort) {
        resorts.remove(resort.id)
        save()
    }
    
    func save() {
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(resorts) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
