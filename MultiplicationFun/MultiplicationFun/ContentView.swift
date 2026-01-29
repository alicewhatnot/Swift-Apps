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
    
    @State private var multiplicands: [String] = []
    @State private var multipliers: [String] = []
    @State private var questionNumber: Int = 1
    
    @State private var showingSettings: Bool = false
    
    var body: some View {
        ZStack {
            if showingSettings {
                VStack {
                    HStack {
                        Text("Number Of Questions")
                        
                        Spacer()
                        
                        Picker("Number of questions", selection: $questionsAmount) {
                            Text("5").tag(5)
                            Text("10").tag(10)
                            Text("20").tag(20)
                        }
                    }
                    
                    Stepper("Up to the \(multiplicationTable) times tables", value: $multiplicationTable, in: 2...20)
                    
                    HStack {
                        Text("Difficulty")
                        
                        Spacer()
                        
                        Picker("Difficulty", selection: $difficulty) {
                            Text("Easy").tag(Difficulty.easy)
                            Text("Medium").tag(Difficulty.medium)
                            Text("Hard").tag(Difficulty.hard)
                        }
                    }
                }
            }
            
            VStack {
                Spacer ()
                
                HStack {
                    ForEach(1..<4, id: \.self) { number in
                        Button {
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
                        } label: {
                            Text("\(number)")
                                .digitButton()
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                
                HStack {
                    Button {
                        showingSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .spacerButton()
                    
                    Button {
                    } label: {
                        Text("\(0)")
                            .digitButton()
                    }
                    .buttonStyle(.plain)
                    
                    Button {} label: {
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .spacerButton()
                }
                
            }
        }
        .padding()
    }
    
    func genarateQuetions() {
        var randomMultiplier: Int = 0
        
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
