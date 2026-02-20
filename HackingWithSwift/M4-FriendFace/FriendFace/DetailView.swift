//
//  DetailView.swift
//  FriendFace
//
//  Created by Michael Gillbanks on 20/02/2026.
//

import SwiftUI

struct DetailView: View {
    var user: User
    
    var body: some View {
        ScrollView {
            VStack() {
                HStack {
                    Text("About")
                        .font(.title)
                        .padding()
                    Spacer()
                }
                HStack {
                    Text("Age: \(String(user.age))")
                    Text("|")
                    Text("Company: \(user.company)")
                    Spacer()
                }
                .font(.headline)
                .padding(.horizontal)
                .padding(.bottom)
                Text(user.about)
                    .font(.subheadline)
                    .padding(.horizontal)
            }
            
            HStack {
                Text("Friends (\(user.friends.count))")
                    .font(.title)
                    .padding()
                Spacer()
            }

            ForEach(user.friends, id: \.id) { item in
                Text(item.name)
                    .font(.headline)
                    .padding()
            }
        }
        .navigationTitle(user.name)
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    let example = User(id: UUID(), isActive: true, name: "Alice Gillbanks", age: 17, company: "Nevado.. Kidding", address: "BS40 7AN Bristol", about: "The Coolest", registered: .now, tags: ["Coolest", "The Best", "#1 Programmer"], friends: [Friend(id: UUID(), name: "Adelaide Krech"), Friend(id: UUID(), name: "Ellie Atkins")])
    DetailView(user: example)
}
