	//
//  ContentView.swift
//  MultiplicationFun
//
//  Created by Michael Gillbanks on 29/01/2026.
//

import SwiftUI

struct ContentView: View {
    enum Difficulty {
        case easy, medium, hard
    }
    
    @State private var multiplicationTable: Int = 12
    @State private var questionsAmount: Int = 5
    @State private var difficulty: Difficulty = .medium
    
    @State private var multipliers: [String] = []
    @State private var multiplicands: [String] = []
    @State private var questionNumber: Int = 1
    
    @State private var correctAnswers: Int = 0
    @State private var userAnswer: String = ""
    
    @State private var showingSettings: Bool = true
    
    var body: some View {
        VStack {
            if showingSettings {
                VStack {
                    HStack {
                        Text("Questions:")
                            .font(.system(size: 24))
                        
                        Spacer()
                        
                        Picker("Number of questions", selection: $questionsAmount) {
                            Text("5").tag(5)
                            Text("10").tag(10)
                            Text("20").tag(20)
                        }
                    }
                    
                    HStack {
                        Text ("Up to the \(multiplicationTable) times tables")
                            .font(.system(size: 24))
                        Stepper("", value: $multiplicationTable, in: 2...20)
                    }

                    HStack {
                        Text("Difficulty:")
                            .font(.system(size: 24))
                        
                        Spacer()
                        
                        Picker("Difficulty", selection: $difficulty) {
                            Text("Easy").tag(Difficulty.easy)
                            Text("Medium").tag(Difficulty.medium)
                            Text("Hard").tag(Difficulty.hard)
                        }
                    }
                }
                .frame(width: 300)
                .padding()
                .background(.ultraThickMaterial)
                .cornerRadius(10)
                .contentShape(Rectangle())
                
            } else {
                Text ("Question \(questionNumber)")
                
                if !showingSettings {
                    Text ("\(multipliers[questionNumber]) x \(multiplicands[questionNumber])")
                        .font(Font.largeTitle.bold())
                } else {
                    Text("No Question")
                        .font(Font.largeTitle.bold())
                }
            }
            
                Text(userAnswer)
                    .font(Font.largeTitle.bold())
                
                Spacer ()
                
                HStack {
                    ForEach(1..<4, id: \.self) { number in
                        Button {
                            userAnswer += "\(number)"
                        } label: {
                            Text("\(number)")
                                .digitButton()
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                HStack {
                    ForEach(4..<7, id: \.self) { number in
                        Button {
                            userAnswer += "\(number)"
                        } label: {
                            Text("\(number)")
                                .digitButton()
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                HStack {
                    ForEach(7..<10, id: \.self) { number in
                        Button {
                            userAnswer += "\(number)"
                        } label: {
                            Text("\(number)")
                                .digitButton()
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                
                HStack {
                    Button {
                        if showingSettings { genarateQuetions() }
                        showingSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .spacerButton()
                    
                    Button {
                        userAnswer += "0"
                    } label: {
                        Text("\(0)")
                            .digitButton()
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        userAnswer = ""
                    } label: {
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .spacerButton()
                }
                
            }
        }    
    
    func genarateQuetions() {
        var randomMultiplier: Int = 0
        multipliers = []
        multiplicands = []
        
        switch difficulty {
            case .easy: randomMultiplier = 1
            case .medium: randomMultiplier = 5
            case .hard: randomMultiplier = 10
        }
        
        for _ in 0..<questionsAmount {
            let multiplicand = "\(Int.random(in: 1...10)*randomMultiplier)"
            multiplicands.append(multiplicand)
            
            let multiplier = "\(Int.random(in: 2...multiplicationTable))"
            multipliers.append(multiplier)
        }
    }
}

#Preview {
    ContentView()
}

struct DigitButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 40, weight: .bold))
            .foregroundStyle(Color.primary.opacity(0.6))
            .frame(width: 110, height: 92)
            .background(Color.primary.opacity(0.2))
            .cornerRadius(10)
            .contentShape(Rectangle())
    }
}

extension View {
    func digitButton() -> some View {
        self.modifier(DigitButton())
    }
}

struct SpacerButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 35, weight: .bold))
            .frame(width: 50, height: 32)
            .padding(30)
            .containerShape(.rect)
            .foregroundStyle(Color.secondary)
    }
}

extension View {
    func spacerButton() -> some View {
        self.modifier(SpacerButton())
    }
}
