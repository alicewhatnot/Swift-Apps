//
//  MissionList.swift
//  Moonshot
//
//  Created by Michael Gillbanks on 06/02/2026.
//

import SwiftUI

struct GridLayout: View {
    let astronauts: [String: Astronaut]
    let missions: [Mission]
    
    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(missions) { mission in
                    NavigationLink {
                        MissionView(mission: mission, astronauts: astronauts)
                    } label: {
                        VStack {
                            Image(mission.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding()
                                .accessibilityHidden(true)
                            
                            VStack {
                                Text(mission.displayName)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                
                                Text(mission.formattedLaunchDate)
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(.lightBackground)
                        }
                        .clipShape(.rect(cornerRadius: 10))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.lightBackground)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(mission.displayName), \(mission.formattedLaunchDate)")
                        .accessibilityHint("Opens mission details")
                    }
                }
            }
            .padding([.horizontal, .bottom])
        }
        .navigationTitle("Moonshot")
        .background(.darkBackground)
        .preferredColorScheme(.dark)
    }
}

struct ListLayout: View {
    let astronauts: [String: Astronaut]
    let missions: [Mission]

    var body: some View {
        List {
            ForEach(missions) { mission in
                NavigationLink {
                    MissionView(mission: mission, astronauts: astronauts)
                } label: {
                    VStack {
                        Image(mission.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding()
                            .accessibilityHidden(true)

                        VStack {
                            Text(mission.displayName)
                                .font(.headline)
                                .foregroundStyle(.white)

                            Text(mission.formattedLaunchDate)
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        .accessibilityElement(children: .ignore)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(.lightBackground)
                    }
                    .background(.darkBackground)
                    .clipShape(.rect(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.lightBackground)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(mission.displayName), \(mission.formattedLaunchDate)")
                    .accessibilityHint("Opens mission details")
                }
                .listRowSeparator(.hidden)
                .background(.darkBackground)
            }
            .listRowBackground(Color.darkBackground)
        }
        .navigationTitle("Moonshot")
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.darkBackground)
        .preferredColorScheme(.dark)
        
    }
}	

#Preview {
    let astronauts: [String: Astronaut] = Bundle.main.decode("astronauts.json")
    let missions: [Mission] = Bundle.main.decode("missions.json")

    return NavigationStack {
        ListLayout(astronauts: astronauts, missions: missions)
    }
}
