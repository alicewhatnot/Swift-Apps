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
    @State private var score: Int = 0
    
    @State private var showingSettings: Bool = true
    @State private var showingAlert = false

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
                .background(.white.opacity(0.75))
                .cornerRadius(10)
                .contentShape(Rectangle())
                
                Button ("Play!") {
                    if showingSettings { genarateQuetions() }
                    showingSettings.toggle()
                }
                    .frame(width: 200, height: 75)
                    .background(.blue)
                    .cornerRadius(35)
                    .foregroundStyle(.white)
                    .font(Font.largeTitle.bold())
                    .padding(50)
                
            } else {
                Text ("Question \(questionNumber) | Score: \(score)")
                Text ("\(multipliers[questionNumber]) x \(multiplicands[questionNumber])")
                    .font(Font.largeTitle.bold())
                    .padding(30)
                Text(userAnswer)
                    .font(Font.system(size: 50))
                    .padding(30)
            }
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
                        verifyAnswer(userAnswer)
                    } label: {
                        Image(systemName: "arrow.right.circle.fill")
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
                        userAnswer.removeLast(1)
                    } label: {
                        Image(systemName: "delete.left")
                    }
                    .spacerButton()
                }
                
            }
            .alert("Score \(score)", isPresented: $showingAlert) {
                Button("OK") { }
            }
            .frame(width: 500)
            .background(.linearGradient(Gradient(colors: [.blue, .purple, .pink]), startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    
    func genarateQuetions() {
        var randomMultiplier: Int = 0
        multipliers = []
        multiplicands = []
        score = 0
        userAnswer = ""
        questionNumber = 1
        
        switch difficulty {
            case .easy: randomMultiplier = 1
            case .medium: randomMultiplier = 5
            case .hard: randomMultiplier = 10
        }
        
        for _ in 0...questionsAmount {
            let multiplicand = "\(Int.random(in: 1...10)*randomMultiplier)"
            multiplicands.append(multiplicand)
            
            let multiplier = "\(Int.random(in: 2...multiplicationTable))"
            multipliers.append(multiplier)
        }
    }
    
    func verifyAnswer(_ answer: String) {
        let correctAnswer = String(Int(multipliers[questionNumber])! * Int(multiplicands[questionNumber])!)
        if answer ==  correctAnswer {
            withAnimation {
                score += 1
                userAnswer = ""
            }
        } else {
            userAnswer = "\(correctAnswer)"
            withAnimation(.easeIn.delay(1)){
                userAnswer = ""
            }
        }
        
        if questionNumber < questionsAmount {
            questionNumber += 1
        } else {
            showingSettings = true
            withAnimation {
                showingAlert = true
            }
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
            .foregroundStyle(Color.white)
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
            .foregroundStyle(.white)
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
