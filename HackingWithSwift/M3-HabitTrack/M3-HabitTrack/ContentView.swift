//
//  ContentView.swift
//  M3-HabitTrack
//
//  Created by Michael Gillbanks on 09/02/2026.
//

import SwiftUI

// I feel like I want to use the fancier navigation arrays here? Or just do the challenge thing

struct ContentView: View {
    @State private var habits = Habits.load()
    @State private var showingAddHabit = false

    var body: some View {
        NavigationStack {
            List {
                ForEach($habits.items) { $habit in
                    HabitView(habit: $habit)
                }
                .onDelete { offsets in
                    habits.items.remove(atOffsets: offsets)
                }
            }
            .navigationTitle("HabitTrack")
            .toolbar {
                ToolbarItem {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabit(habits: habits)
            }
            .onChange(of: habits.items) {
                habits.save()
            }
        }
    }
}

#Preview {
    ContentView()
}
