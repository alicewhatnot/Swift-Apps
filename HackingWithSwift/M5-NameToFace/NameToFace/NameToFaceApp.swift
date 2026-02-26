//
//  NameToFaceApp.swift
//  NameToFace
//
//  Created by Michael Gillbanks on 25/02/2026.
//

import SwiftData
import SwiftUI

@main
struct NameToFaceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Person.self)
        }
    }
}
