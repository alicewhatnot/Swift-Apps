//
//  AddHabitEvent.swift
//  M3-HabitTrack
//
//  Created by Michael Gillbanks on 09/02/2026.
//

import SwiftUI

struct AddHabitEvent: View {
    @Environment(\.dismiss) private var dismiss

    @State private var description = ""
    @State private var selectedHabitID: UUID?
    @State private var date = Date()
    var habits: Habits

    var body: some View {
        NavigationStack {
            Form {
                Section("Habit") {
                    Picker("Habit", selection: $selectedHabitID) {
                        ForEach(habits.items) { habit in
                            Text(habit.name)
                                .tag(habit.id as UUID?)
                        }
                    }
                }

                Section("Description") {
                    TextField("Description", text: $description)
                }
                Section("Date") {
                    DatePicker("Date", selection: $date)
                }
                
            }
            .navigationTitle("Add Habit")
            .toolbar {
                Button("Save") {
                    guard let id = selectedHabitID,
                          let index = habits.items.firstIndex(where: { $0.id == id }) else {
                        return
                    }

                    let event = Habit.HabitEvent(
                        description: description,
                        date: date
                    )

                    habits.items[index].events.append(event)
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    AddHabit(habits: Habits())
}
