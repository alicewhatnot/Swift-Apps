//
//  FlashzillaApp.swift
//  Flashzilla
//
//  Created by Michael Gillbanks on 01/03/2026.
//

import SwiftData
import SwiftUI

@main
struct FlashzillaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Card.self)
    }
}
