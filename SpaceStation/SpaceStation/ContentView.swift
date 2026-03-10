//
//  ContentView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 08/03/2026.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var API_KEY: String = "zdWedlYa0U8CeAAcw8Jkb1IOeFGzsWMHOyPvIFAL"
}

extension View {
    func defaultBackground() -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea() // ensures full screen
            
            Image("stars")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.5)
            
            self
        }
    }
}

struct ContentView: View {
    
    var body: some View {
        Text("Hello, World!")
            .foregroundStyle(.white)
            .defaultBackground()
    }
}

#Preview {
    ContentView()
}


