//
//  ContentView.swift
//  FriendFace
//
//  Created by Michael Gillbanks on 20/02/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingActiveOnly = false
    @State private var sortOrder = [
        SortDescriptor(\User.name),
        SortDescriptor(\User.registered)
    ]
    
    var body: some View {
        NavigationStack {
            UsersView(showingActiveOnly: showingActiveOnly, sortOrder: sortOrder)
                .navigationTitle("FriendFace")
                .toolbar {
                    Button(showingActiveOnly ? "Show Everyone" : "Show Active Only") {
                        showingActiveOnly.toggle()
                    }
                    
                    Menu("Sort", systemImage: "arrow.up.arrow.down") {
                        Picker("Sort", selection: $sortOrder) {
                            Text("Sort by Name")
                                .tag([
                                    SortDescriptor(\User.name),
                                    SortDescriptor(\User.registered)
                                ])
                            Text("Sort by Company")
                                .tag([
                                    SortDescriptor(\User.company),
                                    SortDescriptor(\User.registered)
                                ])
                        }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
