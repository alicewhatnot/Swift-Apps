//
//  M4_SwiftDataProjectApp.swift
//  M4-SwiftDataProject
//
//  Created by Michael Gillbanks on 19/02/2026.
//

import SwiftData
import SwiftUI

@main
struct SwiftDataProjectApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: User.self)
    }
}
