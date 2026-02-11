//
//  HabitView.swift
//  M3-HabitTrack
//
//  Created by Michael Gillbanks on 11/02/2026.
//

import SwiftUI

struct HabitView: View {
    let habit: Habit
    
    var body: some View {
        NavigationLink(habit.name) {
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
}

#Preview {
    // HabitView(habit: Habit)
}
