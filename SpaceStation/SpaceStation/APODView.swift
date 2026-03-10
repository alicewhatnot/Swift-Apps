//
//  APODView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 08/03/2026.
//

import SwiftUI

struct APOD: Codable {
    let copyright: String?
    let explanation: String
    let media_type: String
    let title: String
    let url: String

    var decodedUrl: URL? { URL(string: url) }
    static let placeholder = APOD(copyright: nil, explanation: "Loading Description...", media_type: "image", title: "Loading APOD...", url: "")
}

struct APODView: View {
    @Environment(\.API_KEY) var api_key
    @State private var apod = APOD.placeholder
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: apod.decodedUrl) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 350, height: 350)
                    .cornerRadius(20)
                    .padding(.top)
                    .clipped()
                    
                    if apod.copyright != nil {
                        Text("CC: \(apod.copyright!)")
                            .background(.secondary.opacity(0.5))
                            .foregroundStyle(Color.white)
                            .offset(x: 5, y: -5)
                    }
                }
                Text(apod.explanation)
                    .font(.system(size: 20, weight: .regular, design: .default))
                    .padding()
                
            }
            .preferredColorScheme(.dark)
            .navigationTitle(apod.title)
            .task {
                await loadAPOD()
            }
            .defaultBackground()
        }
    }
    
    func loadAPOD() async {
        guard let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=\(api_key)") else {
            print("Invalid URL")
            return
        }

        do {
            apod = try await NetworkService.fetch(from: url, as: APOD.self)
        } catch {
            print("Failed to load APOD:", error)
        }
    }
}

#Preview {
    APODView()
}


