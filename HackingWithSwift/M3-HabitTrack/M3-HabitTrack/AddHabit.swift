//
//  AddHabit.swift
//  M3-HabitTrack
//
//  Created by Michael Gillbanks on 09/02/2026.
//

import SwiftUI

struct AddHabit: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""

    var habits: Habits

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Name", text: $name)
                }

                Section("Description") {
                    TextField("Description", text: $description)
                }
            }
            .navigationTitle("Add Habit")
            .toolbar {
                Button("Save") {
                    let habit = Habit(
                        name: name,
                        description: description,
                        events: []
                    )
                    habits.items.append(habit)
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    AddHabit(habits: Habits())
}
