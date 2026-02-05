//
//  ContentView.swift
//  WeSplit
//
//  Created by Michael Gillbanks on 19/12/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var checkAmount: Double = 0
    @State private var numberOfPeople: Int = 1
    @State private var tipPercentage: Int = 10
    
    @FocusState private var amountIsFocused: Bool
    
    let tipPercentages = [10,15,20,25,0]
    
    var totalAmount: Double {
        let tipSelection = Double(tipPercentage)
        let tipAmount = checkAmount * (tipSelection / 100)
        let totalAmount = checkAmount + tipAmount
        return totalAmount
    }
    
    var totalperPerson: Double {
        totalAmount / Double(numberOfPeople + 1)
    }
    
    var tipping: Bool { tipPercentage > 0 }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Amount", value: $checkAmount, format: .currency(code: Locale.current.currency?.identifier ?? "GBP"))
                        .keyboardType(.decimalPad)
                        .focused($amountIsFocused)
                    
                    Picker("Number of people", selection: $numberOfPeople) {
                        ForEach(1..<100) {
                            Text("\($0) people")
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section("How much do you want to tip?") {
                    Picker("Tip percentage", selection: $tipPercentage) {
                        ForEach(0..<100) {
                            Text($0, format: .percent)
                        }
                    }
                    .pickerStyle(.navigationLink)

                }
                Section("Payment Per Person") {
                    Text(totalperPerson, format: .currency(code: Locale.current.currency?.identifier ?? "GBP"))
                }
                
                Section("Check total") {
                    Text(totalAmount, format: .currency(code: Locale.current.currency?.identifier ?? "GBP"))
                        .foregroundStyle(tipping ? .primary : Color.red)
                }
            }
            .navigationTitle(Text("WeSplit"))
            .toolbar {
                if amountIsFocused {
                    Button ("Done") {
                        amountIsFocused = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
