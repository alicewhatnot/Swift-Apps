//
//  ContentView.swift
//  RockPaperScissors
//
//  Created by Michael Gillbanks on 30/12/2025.
//

import SwiftUI

struct ChoiceButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 65))
            .padding()
    }
}

extension View {
    func choiceButtonStyle() -> some View {
        self.modifier(ChoiceButtonStyle())
    }
}

struct ContentView: View {
    let moves: [String] = ["Rock", "Paper", "Scissors"]
    
    @State private var appChoice: Int = Int.random(in: 0...2)
    @State private var shouldWin: Bool = Bool.random()
    @State private var playerScore: Int = 0
    
    
    var titleCard: some View {
        Text("Rock Paper Scissors")
            .font(.largeTitle.bold())
            .foregroundStyle(.white)
    }

    
    var appChoiceText: some View {
        VStack {
            Text("App Chooses")
                .font(.title)
            Text(moves[appChoice])
                .font(.title.bold())
        }
    }
    
    var shouldWinText: some View {
        VStack {
            Text("You are aiming to")
                .font(.title)
            if shouldWin {
                Text("Win")
            } else {
                Text("Lose")
            }
        }
        .font(.title.bold())
    }
    
    var moveButtons: some View {
        HStack {
            Spacer(minLength: 30)
            
            Button("🪨") { play(move: 0) }.choiceButtonStyle()
            Button("📄") { play(move: 1) }.choiceButtonStyle()
            Button("✂️") { play(move: 2) }.choiceButtonStyle()
            
            Spacer(minLength: 30)
        }
    }
    
    var scoreDisplay: some View {
        VStack {
            Text("Score: \(playerScore)")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
        }
    }
    
    var body: some View {
        VStack {
            Spacer(minLength: 50)
            
            titleCard
                
            Spacer(minLength: 60)
            
            VStack {
                Spacer()

                appChoiceText
                
                Spacer()

                shouldWinText
                
                Spacer()

                moveButtons
                Spacer()
            }
            .background(.regularMaterial)
            .cornerRadius(50)
            .padding()
            
            Spacer(minLength: 100)
            
            scoreDisplay
            
            Spacer(minLength: 10)
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.teal, .blue]), startPoint: .topTrailing, endPoint: .bottomLeading)
            )        .sensoryFeedback(.increase, trigger: playerScore)
    }
    
    func play(move: Int) -> () {
        if (move == (appChoice + 1) % 3) {
            playerScore = shouldWin ? playerScore + 1 : playerScore - 1
        } else if (move == (appChoice + 2) % 3) {
            playerScore = shouldWin ? playerScore - 1 : playerScore + 1
        }
        
        appChoice = Int.random(in: 0...2)
        shouldWin.toggle()
    }
}

#Preview {
    ContentView()
}
