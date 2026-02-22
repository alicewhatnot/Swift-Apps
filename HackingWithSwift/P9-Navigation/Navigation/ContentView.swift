//
//  ContentView.swift
//  P9-Navigation
//
//  Created by Michael Gillbanks on 06/02/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(1..<5) { number in
                    NavigationLink("select number \(number)", value: number)
                }
                ForEach(1..<5) { number in
                    NavigationLink("select string \(number)", value: String(number))
                }
                
            }
            .toolbar {
                Button("556") {
                    path.append(556)
                }
                
                Button("hello") {
                    path.append("hello")
                }
            }
            .navigationDestination(for: Int.self) { thing in
                Text("int \(thing)")
            }
            .navigationDestination(for: String.self) { _ in
                Text("string")
            }
        }
    }
}

#Preview {
    ContentView()
}
