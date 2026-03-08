//
//  ContentView.swift
//  SnowSeeker
//
//  Created by Michael Gillbanks on 05/03/2026.
//

import SwiftUI

struct ContentView: View {
    enum SortOrder {
        case unsorted, alphabetical, country
    }
    
    let resorts: [Resort] = Bundle.main.decode("resorts.json")
    
    @State private var favourites = Favourites()
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .unsorted
    
    var filteredResorts: [Resort] {
        if searchText.isEmpty {
            resorts
        } else {
            resorts.filter { $0.name.localizedStandardContains(searchText) }
        }
    }
    
    var filteredSortedResorts: [Resort] {
        switch sortOrder {
        case .unsorted: filteredResorts
        case .alphabetical: filteredResorts.sorted { $0.name < $1.name }
        case .country: filteredResorts.sorted { $0.country < $1.country }
        }
    }
        
    var body: some View {
        NavigationSplitView {
            List(filteredSortedResorts) { resort in
                NavigationLink(value: resort) {
                    HStack {
                        Image(resort.country)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 25)
                            .clipShape(.rect(cornerRadius: 5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.black, lineWidth: 1)
                            )
                        
                        VStack(alignment: .leading) {
                            Text(resort.name)
                                .font(.headline)
                            
                            Text("\(resort.runs) runs")
                                .foregroundStyle(.secondary)
                        }
                        
                        if favourites.contains(resort) {
                            Spacer()
                            
                            Image(systemName: "heart.fill")
                                .accessibilityLabel("This is a favourite resort")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("Resorts")
            .navigationDestination(for: Resort.self) { resort in
                ResortView(resort: resort)
            }
            .toolbar {
                Menu("Sort", systemImage: "arrow.up.arrow.down") {
                    Picker("Sort", selection: $sortOrder) {
                        Text("Unsorted")
                            .tag(SortOrder.unsorted)
                        Text("Sort by Resort Name")
                            .tag(SortOrder.alphabetical)
                        Text("Sort by Country")
                            .tag(SortOrder.country)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search for a resort")
        } detail: {
            WelcomeView()
        }
        .environment(favourites)
    }
}

#Preview {
    ContentView()
}
