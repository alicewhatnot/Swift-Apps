//
//  ContentView.swift
//  M3-HabitTrack
//
//  Created by Michael Gillbanks on 09/02/2026.
//

import SwiftUI

// I feel like I want to use the fancier navigation arrays here? Or just do the challenge thing

// Adding a habit event on the home screen makes you choose the event
// Adding an event within a habit view means the habit is inferred

struct ContentView: View {
    @State private var habits = Habits()
    @State private var showingAddHabit = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(habits.items, id: \.id) { habit in
                    HabitView(habit: habit)
                }
                .onDelete { offsets in
                    habits.items.remove(atOffsets: offsets)
                }
            }
            .navigationTitle("HabitTrack")
            .toolbar {
                Button("Add Habit") {
                    showingAddHabit = true
                }                
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabit(habits: habits)
            }
        }
    }
}

#Preview {
    ContentView()
}
