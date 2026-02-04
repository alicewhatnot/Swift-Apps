//
//  AddView.swift
//  iExpense
//
//  Created by Michael Gillbanks on 03/02/2026.
//

import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = 0.0
    @State private var currency = "GBP"
    
    var expenses: Expenses
    
    let types = ["Buisness", "Personal"]
    let currencies = ["GBP", "EUR", "USD"]
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                
                Picker("Type", selection: $type) {
                    ForEach (types, id: \.self) {
                        Text($0)
                    }
                }
                
                TextField("Amount", value: $amount, format: .currency(code: currency))
                    .keyboardType(.decimalPad)
                
                Picker("Currency", selection: $currency) {
                    ForEach (currencies, id: \.self) {
                        Text($0)
                    }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                Button("Save") {
                    let item = ExpenseItem(name: name, type: type, amount: amount, currency: currency)
                    expenses.items.append(item)
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    AddView(expenses: Expenses())
}
