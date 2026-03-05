//
//  ContentView.swift
//  DiceRoll
//
//  Created by Michael Gillbanks on 04/03/2026.
//

import SwiftData
import SwiftUI
import UIKit
internal import Combine

struct ContentView: View {
    @Environment(\.accessibilityReduceMotion) var accessibilityReduceMotion
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Roll.date, order: .reverse) var rolls: [Roll]

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let maxSavedRolls = 100
    
    @State private var numberOfSides: Double = 6
    @State private var numberOfRolls: Double = 1
    @State private var dieResult = 6
    @State private var showingPreviousRolls = false
    @State private var numberOfUpdates = 1
    @State private var isRolling = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(String(dieResult))
                    .font(.system(size: 250, weight: .bold))
                    .accessibilityHidden(isRolling)
            
                Spacer()
                
                Button("Roll Die") {
                    Task {
                        for _ in 0..<Int(numberOfRolls) {
                            await rollDie()
                            UIAccessibility.post(
                                notification: .announcement,
                                argument: "Result \(dieResult)"
                            )
                        }
                    }
                }
                .sensoryFeedback(.impact(weight: .heavy, intensity: 1), trigger: numberOfUpdates)
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
                        .sensoryFeedback(.increase, trigger: numberOfSides)
                        .accessibilityLabel("Number of sides")
                    
                    Slider(value: $numberOfRolls, in: 1...10, step: 1)
                    Text("Number Of Rolls: \(Int(numberOfRolls))")
                        .font(.headline)
                        .sensoryFeedback(.increase, trigger: numberOfRolls)
                        .accessibilityLabel("Number of rolls")

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
    
    func rollDie(duration: Double = 2) async {
        isRolling = true

        if !accessibilityReduceMotion {
            let startTime = Date()
            
            while true {
                let elapsed = Date().timeIntervalSince(startTime)
                
                if elapsed >= duration {
                    numberOfUpdates = 1
                    break
                }
                
                let progress = elapsed / duration
                let curve = pow(1-progress, 3)
                
                if Double.random(in: 0...1) < curve {
                    numberOfUpdates += 1
                    dieResult = Int.random(in: 1...Int(numberOfSides))
                }
                
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
        } else {
            dieResult = Int.random(in: 1...Int(numberOfSides))
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        
        isRolling = false

        modelContext.insert(Roll(dieResult, in: Int(numberOfSides)))
        trimRolls()
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
