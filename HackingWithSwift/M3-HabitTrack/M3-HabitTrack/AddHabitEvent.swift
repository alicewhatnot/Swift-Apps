//
//  AddHabitEvent.swift
//  M3-HabitTrack
//
//  Created by Michael Gillbanks on 09/02/2026.
//

import SwiftUI

struct AddHabitEvent: View {
    @Environment(\.dismiss) private var dismiss

    @State private var description: String = ""
    @State private var date: Date = Date()
    @Binding var habit: Habit

    var body: some View {
        NavigationStack {
            Form {
                Section("Description") {
                    TextField("Description", text: $description)
                }
                Section("Date") {
                    DatePicker("Date", selection: $date)
                }
                
            }
            .navigationTitle(habit.name)
            .toolbar {
                Button("Save") {
                    let event = Habit.HabitEvent(
                        description: description,
                        date: date
                    )

                    habit.events.append(event)
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    AddHabit(habits: Habits())
}
