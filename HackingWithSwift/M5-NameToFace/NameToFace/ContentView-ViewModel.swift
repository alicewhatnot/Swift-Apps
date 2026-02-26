//
//  ContentView-ViewModek.swift
//  NameToFace
//
//  Created by Michael Gillbanks on 26/02/2026.
//

import Foundation
import SwiftData

extension ContentView {
    @Observable
    class ViewModel {
        var searchText = ""

        func filteredPeople(from people: [Person]) -> [Person] {
            if searchText.isEmpty {
                return people
            } else {
                return people.filter {
                    $0.name.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        
        func removePerson(at offsets: IndexSet, from people: [Person], using modelContext: ModelContext) {
            for index in offsets {
                modelContext.delete(people[index])
            }
            do {
                try modelContext.save()
            } catch {
                print("Failed to delete person: \(error)")
            }
        }
    }
}
