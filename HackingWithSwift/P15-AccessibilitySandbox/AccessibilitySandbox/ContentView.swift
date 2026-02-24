//
//  ContentView.swift
//  AccessibilitySandbox
//
//  Created by Michael Gillbanks on 24/02/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var value = 10
    
    var body: some View {
        VStack {
            Button("John Fitzgerald Kennedy") {
                print("Tapped")
            }
            .accessibilityInputLabels(["John Fitzgerald Kennedy", "Kennedy", "JFK"])
        }
    }
}

#Preview {
    ContentView()
}
