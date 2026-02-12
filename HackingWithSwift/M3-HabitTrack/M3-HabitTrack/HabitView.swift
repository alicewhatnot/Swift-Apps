//
//  HabitView.swift
//  M3-HabitTrack
//
//  Created by Michael Gillbanks on 11/02/2026.
//

import SwiftUI

struct HabitView: View {
    @State private var showingAddHabitEvent = false
    @Binding var habit: Habit
    
    var body: some View {
        NavigationLink {
            VStack {
                HStack {
                    Text(habit.description)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(habit.events.count)")
                        .font(.title.bold())
                }
                .padding()
                    
                List {
                    ForEach(habit.events) { event in
                        VStack(alignment: .leading) {
                            Text(event.description)
                            Text(event.formattedDate)
                                .font(.caption)
                        }
                    }
                }

            }
            .navigationTitle(habit.name)
            .toolbar {
                Button {
                    showingAddHabitEvent = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        } label: {
            Text(habit.name)
        }
        .sheet(isPresented: $showingAddHabitEvent) {
            AddHabitEvent(habit: $habit)
        }
    }
}
