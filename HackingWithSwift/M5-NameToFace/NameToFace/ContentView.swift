//
//  ContentView.swift
//  NameToFace
//
//  Created by Michael Gillbanks on 25/02/2026.
//

import PhotosUI
import SwiftUI

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\Person.name)])
    private var people: [Person]

    @State private var viewModel = ViewModel()
    @State private var showingAddView = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredPeople(from: people)) { person in
                    HStack {
                        NavigationLink(value: person) {
                            if let uiImage = person.uiImage {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipped()
                                    .cornerRadius(15)
                                    .padding(.trailing)
                                    .accessibilityHidden(true)
                            }

                            Text(person.name)
                                .font(.headline)
                        }
                    }
                }
                .onDelete { offsets in
                    viewModel.removePerson(
                        at: offsets,
                        from: viewModel.filteredPeople(from: people),
                        using: modelContext
                    )
                }
            }
            .searchable(text: $viewModel.searchText)
            .toolbar {
                Button {
                    showingAddView = true
                } label: {
                    Label("Add Face", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddView) {
                AddView()
            }
            .navigationTitle("NameToFace")
            .navigationDestination(for: Person.self) { person in
                DetailView(person: person)
            }
            
        }
    }
}

#Preview {
    ContentView()
}
