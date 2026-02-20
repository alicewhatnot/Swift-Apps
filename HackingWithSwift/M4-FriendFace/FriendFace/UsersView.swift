//
//  UsersView.swift
//  FriendFace
//
//  Created by Michael Gillbanks on 20/02/2026.
//

import SwiftUI
import SwiftData

struct UsersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var users: [User]
    
    init(showingActiveOnly: Bool, sortOrder: [SortDescriptor<User>]) {
        _users = Query(
            filter: #Predicate<User> { user in
                !showingActiveOnly || user.isActive
            },
            sort: sortOrder
        )
    }
    
    var body: some View {
        List(users, id: \.id) { item in
            NavigationLink(value: item) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(item.isActive ? "🟢" : "🔵")
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
    }
    
    func loadUsers() async {
        guard users.isEmpty else {
            print ("Users already loaded. No need to decode JSON.")
            return
        }
        
        guard let url = URL(string: "https://www.hackingwithswift.com/samples/friendface.json") else {
            print("Invalid URL")
            return
        }
        
        print("Loading User Information")
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let decodedUsers = try decoder.decode([User].self, from: data)
            
            for user in decodedUsers {
                modelContext.insert(user)
            }
            try modelContext.save()
            
        } catch {
            print("Invalid data: \(error)")
        }
    }
}
