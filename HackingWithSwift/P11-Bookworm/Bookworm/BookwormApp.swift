//
//  BookwormApp.swift
//  Bookworm
//
//  Created by Michael Gillbanks on 18/02/2026.
//

import SwiftData
import SwiftUI

@main
struct BookwormApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Book.self)
    }
}
