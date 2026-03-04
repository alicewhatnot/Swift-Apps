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

    let maxSavedRolls = 100
    
    @State private var numberOfSides: Double = 6
    @State private var numberOfRolls: Double = 1
    @State private var dieResult = 6
    @State private var showingPreviousRolls = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Future functionality replace this with an automatically scrolling grid or just random numbers, see rollDie()
                Text(String(dieResult))
                    .font(.system(size: 250, weight: .bold))
                
                Spacer()
                
                Button("Roll Die") {
                    for _ in 0..<Int(numberOfRolls) {
                        rollDie()
                    }
                }
                
                .padding()
                .frame(width: 200)
                .font(.largeTitle)
                .foregroundStyle(.white)
                .background(.blue)
                .clipShape(.capsule)
                
                VStack {
                    Slider(value: $numberOfSides, in: 1...100, step: 1)
                    Text("Sides: \(Int(numberOfSides))")
                        .font(.headline)
                    
                    Slider(value: $numberOfRolls, in: 1...10, step: 1)
                    Text("Number Of Rolls: \(Int(numberOfRolls))")
                        .font(.headline)
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 20)
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
        // Every time this is called it will wait like a second to roll the die
        // This will give a very satisfying result with multiple die rolls where it will roll, stop then roll again
        
        dieResult = Int.random(in: 1...Int(numberOfSides))
        modelContext.insert(Roll(dieResult, in: Int(numberOfSides)))
        
        trimRolls()
        
        #if DEBUG
        // For deleting during testing
        //try? modelContext.delete(model: Roll.self)
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
