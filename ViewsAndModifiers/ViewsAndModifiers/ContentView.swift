//
//  ContentView.swift
//  ViewsAndModifiers
//
//  Created by Michael Gillbanks on 27/12/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Button("Hello, world!") {
                print (type(of: self.body))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.red))
    }
}

#Preview {
    ContentView()
}
