//
//  ContentView.swift
//  EasyAsPi
//
//  Created by Michael Gillbanks on 22/01/2026.
//

import SwiftUI

struct DigitButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 40, weight: .bold))
            .foregroundStyle(.black.opacity(0.6))
            .frame(width: 110, height: 92)
            .background(Color.secondary.opacity(0.2))
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

extension String {
    func substring(from start: Int, length: Int) -> String {
        guard start >= 0, length > 0 else { return "" }
        let startIndexSafe = index(startIndex, offsetBy: min(start, count), limitedBy: endIndex) ?? endIndex
        let endIndexSafe = index(startIndexSafe, offsetBy: min(length, count - start), limitedBy: endIndex) ?? endIndex
        return String(self[startIndexSafe..<endIndexSafe])
    }
}

struct ContentView: View {
    @State private var piDigits = ""
    
    @State private var digit: String = ""
    @State private var enteredDigits: String = ""
    @State private var numDigitsEntered: Int = 0
    
    @State private var nextFewDigits: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("\(numDigitsEntered)")
                    .font(.system(size: 40, weight: .semibold))
                    .padding(20)
                
            }
            Spacer()
            
            GeometryReader { geo in
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Text("3.\(enteredDigits)")
                                .font(.system(size: 50, weight: .bold))
                                .monospacedDigit()
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                                .id("digits")
                        }
                        .frame(width: geo.size.width / 2, alignment: .trailing)
                        .mask(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: .black, location: 0.15),
                                    .init(color: .black, location: 1.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }
                    .onChange(of: enteredDigits) {
                        proxy.scrollTo("digits", anchor: .trailing)
                    }
                }
                Text ("\(nextFewDigits)")
                    .frame(width: geo.size.width, alignment: .trailing)
                    .font(.system(size: 50, weight: .bold))
                    .clipped()
                    .foregroundStyle(.gray)
                    .monospacedDigit()
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .frame(height: 50)
            
            
            Spacer()

            
            HStack {
                ForEach(1..<4, id: \.self) { number in
                    Button {
                        if nextFewDigits.isEmpty {
                            verifyDigit(Character(String(number)))
                        }
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
                        if nextFewDigits.isEmpty {
                            verifyDigit(Character(String(number)))
                        }
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
                        if nextFewDigits.isEmpty {
                            verifyDigit(Character(String(number)))
                        }
                    } label: {
                        Text("\(number)")
                            .digitButton()
                    }
                    .buttonStyle(.plain)
                }
            }
            HStack {
                Spacer()
                    .spacerButton()
                
                Button {
                    if nextFewDigits.isEmpty {
                        verifyDigit(Character(String(0)))
                    }
                } label: {
                    Text("\(0)")
                        .digitButton()
                }
                .buttonStyle(.plain)
                
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    reset()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                
                .spacerButton()
            }
            
        }
        
        .onAppear(perform: getPi)
    }
    
    func getPi() {
        if let piDigitsURL = Bundle.main.url(forResource: "tenThousandDigitsOfPi", withExtension: "txt") {
            if let foundPiDigits = try? String(contentsOf: piDigitsURL, encoding: .ascii) {
                piDigits = foundPiDigits
                return
            }
        }
    }
    
    func verifyDigit(_ digit: Character) {
        let index = piDigits.index(
            piDigits.startIndex,
            offsetBy: numDigitsEntered
        )
        
        let digitToMatch = piDigits[index]
        
        if digit == digitToMatch {
            
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            enteredDigits.append("\(digit)")
            numDigitsEntered += 1
            nextFewDigits = ""
        } else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)

            nextFewDigits = piDigits.substring(from: numDigitsEntered, length: 6)
        }
    }
    
    func reset() {
        nextFewDigits = ""
        numDigitsEntered = 0
        enteredDigits = ""
    }
    
}

#Preview {
    ContentView()
}


