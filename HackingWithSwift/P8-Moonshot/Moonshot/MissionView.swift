//
//  MissionView.swift
//  Moonshot
//
//  Created by Michael Gillbanks on 04/02/2026.
//

import SwiftUI

struct MissionView: View {
    struct CrewMember {
        let role: String
        let astronaut: Astronaut
    }
    
    let mission: Mission
    let crew: [CrewMember]
    
    var body: some View {
        ScrollView {
            VStack {
                Image(mission.image)
                    .resizable()
                    .scaledToFit()
                    .containerRelativeFrame(.horizontal) { width, axis in
                        width * 0.6
                    }
                    .accessibilityLabel("\(mission.displayName) mission patch")
                
                HStack {
                    Text("Launch Date: \(mission.formattedLaunchDate)")
                        .padding(.horizontal)
                        .padding(.top)
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    HorizontalBar()
                    
                    Text("Mission Highlights")
                        .font(.title.bold())
                        .padding(.bottom, 5)
                    
                    Text(mission.description)
                    
                    HorizontalBar()
                    
                    Text("Crew")
                        .font(.title.bold())
                        .padding(.bottom, 5)
                }
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(crew, id: \.role) { CrewMember in
                            NavigationLink {
                                AstronautView(astronaut: CrewMember.astronaut)
                            } label: {
                                HStack {
                                    Image(CrewMember.astronaut.id)
                                        .resizable()
                                        .frame(width: 104, height: 72)
                                        .clipShape(.capsule)
                                        .overlay(
                                            Capsule()
                                                .strokeBorder(.white, lineWidth: 1)
                                            )
                                        .accessibilityHidden(true)
                                    
                                    VStack(alignment: .leading) {
                                        Text(CrewMember.astronaut.name)
                                            .foregroundStyle(.white)
                                            .font(.headline)
                                        
                                        Text(CrewMember.role)
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                    .accessibilityElement(children: .combine)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .padding(.bottom)
        }
        .navigationTitle(mission.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .background(.darkBackground)
    }
    
    init(mission: Mission, astronauts: [String: Astronaut]) {
        self.mission = mission
        self.crew = mission.crew.map { member in
            if let astronaut = astronauts[member.name] {
                return CrewMember(role: member.role, astronaut: astronaut)
            } else {
                fatalError("Missing \(member.name)")
            }
        }
    }
}

#Preview {
    let missions: [Mission] = Bundle.main.decode("missions.json")
    let astronauts: [String: Astronaut] = Bundle.main.decode("astronauts.json")
    
    MissionView(mission: missions[0], astronauts: astronauts)
        .preferredColorScheme(.dark)
}
