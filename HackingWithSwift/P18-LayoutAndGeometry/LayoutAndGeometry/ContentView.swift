//
//  ContentView.swift
//  LayoutAndGeometry
//
//  Created by Michael Gillbanks on 03/03/2026.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        GeometryReader { fullView in
            ScrollView(.vertical) {
                ForEach(0..<50) { index in
                    GeometryReader { proxy in
                        let minY = proxy.frame(in: .global).minY
                        let screenHeight = fullView.size.height
                        
                        let scale = 0.5 + 0.5 * (minY / screenHeight)
                        let hue = minY / screenHeight
                        let saturation = 1.0
                        let brightness = 1.0
                        
                        Text("Row #\(index)")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .background(Color(hue: hue, saturation: saturation, brightness: brightness))
                            .rotation3DEffect(.degrees(proxy.frame(in: .global).minY - fullView.size.height / 2) / 5, axis: (x: 0, y: 1, z: 0))
                            .opacity(proxy.frame(in: .global).minY * 0.005)
                            .scaleEffect(scale)
                    }
                    .frame(height: 40)
                }
            }
        }
    }
}
#Preview {
    ContentView()
}
