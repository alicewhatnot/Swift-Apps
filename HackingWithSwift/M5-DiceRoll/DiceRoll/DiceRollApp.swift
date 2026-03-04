//
//  DiceRollApp.swift
//  DiceRoll
//
//  Created by Michael Gillbanks on 04/03/2026.
//

import SwiftData
import SwiftUI

@main
struct DiceRollApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Roll.self)
    }
}
