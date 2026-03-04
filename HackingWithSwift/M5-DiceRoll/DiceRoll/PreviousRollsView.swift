//
//  PreviousRollsView.swift
//  DiceRoll
//
//  Created by Michael Gillbanks on 04/03/2026.
//

import SwiftUI

struct PreviousRollsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var rolls: [Roll]
    
    var body: some View {
        NavigationStack {
            List {
                if rolls.isEmpty {
                    ContentUnavailableView("No Rolls Yet!", systemImage: "dice", description: Text("Roll a die a few times for the results to appear here."))
                }
                ForEach(rolls) { roll in
                    HStack {
                        Text(String(roll.number))
                            .font(.largeTitle)
                        
                        Spacer()
                        
                        VStack {
                            Text("\(String(roll.numberOfSides ?? 6)) Sides")
                                .font(.subheadline)
                            
                            Text(roll.formattedDate)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .navigationTitle("Previous Rolls")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

