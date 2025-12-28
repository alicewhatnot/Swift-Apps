//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Michael Gillbanks on 21/12/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var countries: [String] = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"].shuffled()
    @State private var correctAnswer: Int = Int.random(in: 0...2)
    
    @State private var showingScore: Bool = false
    @State private var scoreTitle: String = ""
    @State private var score: Int = 0
    
    @State private var questionsAsked: Int = 0
    @State private var round: Int = 1
    let maxQuestions: Int = 8
    
    var body: some View {
        ZStack() {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3)],
                           center: .top, startRadius: 200, endRadius: 700)
            .ignoresSafeArea()
            
            VStack() {
                Spacer()
                
                Text("Guess The Flag")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            flagTapped(number)
                        } label: {
                            Image(countries[number])
                                .clipShape(.rect(cornerRadius: 10))
                                .shadow(radius: 10)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))
                
                Spacer()
                Spacer()
                
                Text("Score: \(score)")
                    .foregroundStyle(Color.white)
                    .font(.title.bold())
                
                Spacer()

                Text("Round: \(round)")
                    .foregroundStyle(Color.white)
                    .font(.title.bold())
                
                Spacer()
            }
            .padding()
        }
        
        .alert(scoreTitle, isPresented: $showingScore) {
            if questionsAsked >= maxQuestions {
                Button("Play Again", action: restart)
            } else {
                Button("Continue", action: askQuestion)
            }
        } message: {
            if questionsAsked >= maxQuestions {
                Text("Your total score is \(score)/\(maxQuestions)")
            }   else {
                Text("Your score is \(score)")
            }
        }
    }
        
    
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct!"
            score += 1
        } else {
            scoreTitle = "Wrong! That's \(countries[number])!"
        }
        
        showingScore = true
        questionsAsked += 1
        round += 1
        
        if questionsAsked == maxQuestions {
            round -= 1
        }
    }
    
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }
    
    func restart() {
        score = 0
        round = 1
        questionsAsked = 0
        askQuestion()
    }
}

#Preview {
    ContentView()
}
