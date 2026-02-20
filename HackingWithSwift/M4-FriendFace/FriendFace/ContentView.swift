//
//  ContentView.swift
//  FriendFace
//
//  Created by Michael Gillbanks on 20/02/2026.
//

import SwiftUI


struct ContentView: View {
    @State private var users = [User]()
    
    var body: some View {
        NavigationStack {
            List(users, id: \.id) { item in
                NavigationLink(value: item) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(item.isActive ? "🟢" : "🔵")
                                .opacity(1)
                                .font(.system(size: 10))
                            Text(item.name)
                                .font(.headline)
                        }
                        HStack {
                            Text(String(item.age))
                            Text("|")
                            Text(item.company)
                            Text("|")
                            Text(String(item.friends.count))
                        }
                            .font(.subheadline)
                    }
                }
            }
            .task {
                await loadUsers()
            }
            .navigationDestination(for: User.self) { user in
                DetailView(user: user)
            }
            .navigationTitle("FriendFace")
        }
    }
    
    func loadUsers() async {
        guard let url = URL(string: "https://www.hackingwithswift.com/samples/friendface.json") else {
            print("Invalid URL")
            return
        }
        
        guard users == [] else {
            print ("Users already loaded. No need to decode JSON.")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            users = try decoder.decode([User].self, from: data)
            
        } catch {
            print("Invalid data: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
