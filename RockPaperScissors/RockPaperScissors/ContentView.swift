//
//  ContentView.swift
//  RockPaperScissors
//
//  Created by Michael Gillbanks on 30/12/2025.
//

import SwiftUI

struct ContentView: View {
    var moves: [String] = ["Rock", "Paper", "Scissors"]
    
    @State private var appChoice: String 
    @State private var userGoal: Bool
    
    
    var body: some View {
        Text("\(appChoice.rawValue)")
        Text("\(userGoal.rawValue)")
    }
}

#Preview {
    ContentView()
}
