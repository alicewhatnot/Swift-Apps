//
//  UsersView.swift
//  M4-SwiftDataProject
//
//  Created by Michael Gillbanks on 19/02/2026.
//

import SwiftData
import SwiftUI

struct UsersView: View {
    @Environment(\.modelContext) var modelContext
    @Query var users: [User]
    var body: some View {
        List(users) { user in
            HStack {
                Text(user.name)
                
                Spacer()
                
                Text(String(user.jobs.count))
                    .fontWeight(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
            }
        }
        .onAppear(perform: addSample)
    }
    
    init(minimumJoinDate: Date, sortOrder: [SortDescriptor<User>]) {
        _users = Query(filter: #Predicate<User> { user in
            user.joinDate >= minimumJoinDate
        }, sort: sortOrder)
    }
    
    func addSample() {
        let user1 = User(name: "Piper", city: "NYC", joinDate: .now)
        let job1 = Job(name: "Blow up a city", priority: 1)
        let job2 = Job(name: "Die", priority: 2)
        
        modelContext.insert(user1)
        
        user1.jobs.append(job1)
        user1.jobs.append(job2)
    }
}

#Preview {
    UsersView(minimumJoinDate: .now, sortOrder: [SortDescriptor(\User.name)])
        .modelContainer(for: User.self)
}
