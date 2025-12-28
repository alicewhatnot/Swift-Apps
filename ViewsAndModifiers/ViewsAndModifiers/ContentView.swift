//
//  ContentView.swift
//  ViewsAndModifiers
//
//  Created by Michael Gillbanks on 27/12/2025.
//

import SwiftUI

struct Title: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundColor(.blue)
            .fontWeight(.bold)
    }
}

extension View {
    func titleStyle(_ content: String) -> some View {
        Text(content)
            .modifier(Title())
    }
}

struct ContentView: View {
    var body: some View {
        titleStyle("Shot on iPhone")
    }
}

#Preview {
    ContentView()
}
