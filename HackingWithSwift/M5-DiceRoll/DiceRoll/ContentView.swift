//
//  ContentView.swift
//  DiceRoll
//
//  Created by Michael Gillbanks on 04/03/2026.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Roll.date, order: .reverse) var rolls: [Roll]

    let maxSavedRolls = 4
    
    @State private var dieResult = 6
    @State private var showingPreviousRolls = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Future functionality replace this with an automatically scrolling grid
                Image("\(dieResult)die")
                    .resizable()
                    .scaledToFit()
                    .padding(100)
                    .frame(maxWidth: .infinity)
                
                Spacer()
                
                Button("Roll Die") {
                    rollDie()
                }
                .padding()
                .frame(width: 200)
                .font(.largeTitle)
                .foregroundStyle(.white)
                .background(.blue)
                .clipShape(.capsule)
            }
            .toolbar {
                Button("Previous Rolls") {
                    showingPreviousRolls = true
                }
            }
            .sheet(isPresented: $showingPreviousRolls) { PreviousRollsView(rolls: rolls) }
        }
    }
    
    func rollDie() {
        dieResult = Int.random(in: 1...6)
        modelContext.insert(Roll(dieResult))
        
        trimRolls()
        
        #if DEBUG
        // For deleting during testing
        // try? modelContext.delete(model: Roll.self)
        #endif
        
        try? modelContext.save()
    }
    
    func trimRolls() {
        guard rolls.count > maxSavedRolls else { return }
        let excess = rolls.dropFirst(maxSavedRolls)

        for roll in excess {
            modelContext.delete(roll)
        }
    }
}

#Preview {
    ContentView()
}
