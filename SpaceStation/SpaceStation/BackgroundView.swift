//
//  BackgroundView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 11/03/2026.
//

import SwiftUI

// May not actually be useful but you should totally try fix because it would be awesome
// If implementing, don't forget to use the with/without streaks attribute to ensure that with motion off streaks are off

// Also please find a cleaner space image

struct Streak: View {
    let size: CGSize
    
    @State private var x: CGFloat = 0
    @State private var y: CGFloat = -50
    @State private var opacity: Double = 0
    
    var body: some View {
        Capsule()
            .fill(.white)
            .frame(width: CGFloat.random(in: 60...120), height: 2)
            .rotationEffect(.degrees(-35))
            .blur(radius: 1)
            .opacity(opacity)
            .position(x: x, y: y)
            .onAppear {
                // Spread initial positions across the whole screen, not just the top
                x = .random(in: 0...size.width)
                y = .random(in: 0...size.height)
                animate()
            }
    }

    func animate() {
        // Pick a fresh random start along the top (and a bit left of screen
        // to account for the diagonal drift)
        let startX = CGFloat.random(in: -100...size.width)
        let startY = CGFloat.random(in: -80 ... -20)
        let duration = Double.random(in: 1.5...3)
        let drift = CGFloat.random(in: 200...400)

        withAnimation(.linear(duration: 0)) {
            x = startX
            y = startY
            opacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.linear(duration: duration)) {
                opacity = 1
            }
            withAnimation(.linear(duration: duration)) {
                y = size.height + 50
                x = startX + drift  // use startX as base, not accumulated x
                opacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 2...6)) {
                animate()
            }
        }
    }
}

struct StreakLayer: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<6) { _ in
                    Streak(size: geo.size)
                }
            }
        }
        .ignoresSafeArea()
    }
}

extension View {
    func defaultBackground(withStreaks: Bool = true) -> some View {
        ZStack {
            // Use a screen-size GeometryReader so the image never
            // reacts to content layout changes above it
            GeometryReader { geo in
                Image("stars")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .opacity(0.3)
            }
            .ignoresSafeArea()

            if withStreaks {
                StreakLayer()
            }

            self
        }
    }
}
