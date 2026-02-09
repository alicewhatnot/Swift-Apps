//
//  ContentView.swift
//  M3-HabitTrack
//
//  Created by Michael Gillbanks on 09/02/2026.
//

import SwiftUI

// I feel like I want to use the fancier navigation arrays here?
// Adding a habit event on the home screen makes you choose the event
// Adding an event within a habit view means the habit is inferred

struct ContentView: View {
    @State private var habits = Habits()
    @State private var showingAddHabit = false
    @State private var showingAddHabitEvent = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(habits.items, id: \.id) { habit in
                    NavigationLink(habit.name) {
                        // Replace this with its own view
                        VStack(alignment: .leading) {
                            Text(habit.name)
                                .font(.headline)
                            Text(habit.description)
                                .font(.subheadline)
                        }
                        
                        List {
                            ForEach(habit.events, id: \.id) { event in
                                Text(event.description)
                                Text(event.formattedDate)
                            }
                        }
                    }
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
                
                Button ("Add Habit Event") {
                    showingAddHabitEvent = true
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabit(habits: habits)
            }
            .sheet(isPresented: $showingAddHabitEvent) {
                AddHabitEvent(habits: habits)
            }
        }
    }
}

#Preview {
    ContentView()
}
