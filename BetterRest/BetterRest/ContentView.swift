//
//  ContentView.swift
//  BetterRest
//
//  Created by Michael Gillbanks on 14/01/2026.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp: Date = defaultWakeTime
    @State private var sleepAmount: Double = 8
    @State private var coffeeAmount: Int = 1
    
    @State private var alertTitle: String = ""
    @State private var showingAlert: Bool = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section ("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents:
                            .hourAndMinute)
                    .labelsHidden()
                }
                
                Section ("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section ("Daily coffee intake") {
                    Picker("^[Cups](inflect: true)", selection: $coffeeAmount) {
                        ForEach (1...20, id: \.self) {
                            Text ("\($0)")
                        }
                    }
                }
                
                Section ("You should go to sleep at") {
                    Text("\(calculateBedtime(wakeUp: wakeUp, sleepAmount: sleepAmount, coffeeAmount: coffeeAmount, showingAlert: showingAlert).formatted(date: .omitted, time: .shortened))")
            }
            
            .navigationTitle("Better Rest")
            
            }
        }
    }
    
func calculateBedtime(wakeUp: Date, sleepAmount: Double, coffeeAmount: Int, showingAlert: Bool) -> Date {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(
                wake: Double(hour + minute),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime
            
        } catch {
            return Date.now
        }
    }
}

#Preview {
    ContentView()
}
