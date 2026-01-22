//
//  ContentView.swift
//  Animations
//
//  Created by Michael Gillbanks on 22/01/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var animationAmount: Double = 1
    var body: some View {
        Button ("Tap Me") {
        }
        .padding(50)
        .background(.red)
        .foregroundStyle(.white)
        .clipShape(.circle)
        .overlay(
            Circle()
                .stroke(.red)
                .scaleEffect(animationAmount)
                .opacity(2 - animationAmount)
                .animation(
                    .easeOut(duration: 1)
                    .repeatForever(autoreverses: false),
                    value: animationAmount
                )
        )
        .onAppear {
            animationAmount = 2
        }
    }
}

#Preview {
    ContentView()
}
