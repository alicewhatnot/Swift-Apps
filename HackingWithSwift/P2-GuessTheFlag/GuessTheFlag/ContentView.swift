//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Michael Gillbanks on 21/12/2025.
//

import SwiftUI

struct FlagImage: View {
    let country: String
    
    var body: some View {
        Image(country)
            .clipShape(.rect(cornerRadius: 10))
            .shadow(radius: 10)
    }
}

struct ContentView: View {
    @State private var countries: [String] = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"].shuffled()
    @State private var correctAnswer: Int = Int.random(in: 0...2)
    
    let labels = [
        "Estonia": "Flag with three horizontal stripes. Top stripe blue, middle stripe black, bottom stripe white.",
        "France": "Flag with three vertical stripes. Left stripe blue, middle stripe white, right stripe red.",
        "Germany": "Flag with three horizontal stripes. Top stripe black, middle stripe red, bottom stripe gold.",
        "Ireland": "Flag with three vertical stripes. Left stripe green, middle stripe white, right stripe orange.",
        "Italy": "Flag with three vertical stripes. Left stripe green, middle stripe white, right stripe red.",
        "Nigeria": "Flag with three vertical stripes. Left stripe green, middle stripe white, right stripe green.",
        "Poland": "Flag with two horizontal stripes. Top stripe white, bottom stripe red.",
        "Spain": "Flag with three horizontal stripes. Top thin stripe red, middle thick stripe gold with a crest on the left, bottom thin stripe red.",
        "UK": "Flag with overlapping red and white crosses, both straight and diagonally, on a blue background.",
        "Ukraine": "Flag with two horizontal stripes. Top stripe blue, bottom stripe yellow.",
        "US": "Flag with many red and white stripes, with white stars on a blue background in the top-left corner."
    ]
    
    @State private var showingScore: Bool = false
    @State private var scoreTitle: String = ""
    @State private var score: Int = 0
    
    @State private var questionsAsked: Int = 0
    @State private var round: Int = 1
    
    @State private var animationAmount: Double = 0
    @State private var selectedFlag: Int? = nil
    
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
                            selectedFlag = number
                            withAnimation(.easeInOut(duration: 0.6)) {
                                animationAmount += 360
                            }
                            flagTapped(number)
                        } label: {
                            FlagImage(country: countries[number])
                                .rotation3DEffect(
                                    Angle(degrees: selectedFlag == number ? animationAmount : 0),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                                .opacity(
                                    selectedFlag == nil || selectedFlag == number ? 1 : 0.25
                                )
                                .rotation3DEffect(
                                    Angle(degrees: selectedFlag != number || selectedFlag == nil ? -1 * animationAmount : 0),
                                    axis: (x: 1, y: 0, z: 0)
                                )
                                .accessibilityLabel(labels[countries[number], default: "Unknown flag"])
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
        selectedFlag = nil
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
