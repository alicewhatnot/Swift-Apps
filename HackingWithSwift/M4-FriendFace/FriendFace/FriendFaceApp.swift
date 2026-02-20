//
//  FriendFaceApp.swift
//  FriendFace
//
//  Created by Michael Gillbanks on 20/02/2026.
//

import SwiftUI
import SwiftData

@main
struct FriendFaceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: User.self)
    }
}
