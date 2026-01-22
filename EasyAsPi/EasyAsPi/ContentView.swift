//
//  ContentView.swift
//  EasyAsPi
//
//  Created by Michael Gillbanks on 22/01/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var piDigits = ""
    
    @State private var score: Int = 0
    @State private var digit: String = ""
    @State private var enteredDigits: String = ""
    @State private var digitsEntered: Int = 0
        
    var body: some View {
        VStack {
            Text("3.\(enteredDigits)")
            TextField("help", text: $digit)
                .keyboardType(.numberPad)
                .onChange(of: digit) {
                    let charDigit = Character(digit)
                    if verifyDigit(charDigit) {
                        score += 1
                        enteredDigits += digit
                    } else {
                        score = 0
                        enteredDigits = ""
                    }
                    digit = ""
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
    
    func verifyDigit(_ digit: Character) -> Bool {
        let index = piDigits.index(
            piDigits.startIndex,
            offsetBy: digitsEntered + 1
        )
        
        let digitToMatch = piDigits[index]
        
        return digit == digitToMatch
    }
}

#Preview {
    ContentView()
}


