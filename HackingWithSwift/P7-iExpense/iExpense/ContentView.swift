//
//  ContentView.swift
//  iExpense
//
//  Created by Michael Gillbanks on 03/02/2026.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id: UUID = UUID()
    let name: String
    let type: String
    let amount: Double
    let currency: String
}

@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }
        
        items = []
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()
    
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Personal")) {
                    ForEach(expenses.items) { item in
                        if item.type == "Personal" {
                            HStack {
                                Text(item.name)
                                    .font(Font.headline)
                                
                                Spacer()
                                
                                Text(item.amount, format: .currency(code: item.currency).notation(item.amount > 999 ? .compactName : .automatic).precision(item.amount > 100 ? .fractionLength(0) : .fractionLength(2)))
                            }
                        }
                    }
                    .onDelete(perform: removeItems)
                    
                    if !expenses.items.contains(where: { $0.type == "Personal" }) {
                        Text("You have no personal expenses.")
                    }
                }
                
                Section(header: Text("Business")) {
                    ForEach(expenses.items) { item in
                        if item.type == "Buisness" {
                            HStack {
                                Text(item.name)
                                    .font(Font.headline)
                                
                                Spacer()
                                
                                Text(item.amount, format: .currency(code: item.currency).notation(item.amount > 999 ? .compactName : .automatic).precision(item.amount > 100 ? .fractionLength(0) : .fractionLength(2)))
                            }
                        }
                    }
                    .onDelete(perform: removeItems)
                    
                    if !expenses.items.contains(where: { $0.type == "Buisness" }) {
                        Text("You have no buisness expenses.")
                    }
                }
            }
            .navigationTitle(("iExpense"))
            .toolbar {
                Button("Add Expense", systemImage: "plus") {
                    showingAddExpense = true
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
        }
    }
    
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}
