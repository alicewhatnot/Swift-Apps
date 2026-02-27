//
//  HotProspectsApp.swift
//  HotProspects
//
//  Created by Michael Gillbanks on 26/02/2026.
//

import SwiftData
import SwiftUI

@main
struct HotProspectsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Prospect.self)
    }
}
