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
                x = .random(in: 0...size.width)
                animate()
            }
    }
    
    func animate() {
        // Snap to starting position with no animation
        withAnimation(.linear(duration: 0)) {
            y = -50
            x = .random(in: 0...size.width)
            opacity = 0
        }
        
        // Small delay to let the reset render, then animate downward
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            opacity = 1
            withAnimation(.linear(duration: Double.random(in: 1.5...3))) {
                y = size.height + 50
                x += CGFloat.random(in: 200...400)
                opacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 3...8)) {
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
    func defaultBackground(withStreaks: Bool = false) -> some View {
        ZStack {
            Image("stars")
                .resizable()
                .opacity(0.5)
                .ignoresSafeArea()

            // Using and false to disable the broken streaks
            if withStreaks && false {
                StreakLayer()
            }

            self
        }
    }
}
