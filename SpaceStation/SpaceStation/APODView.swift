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
    @State private var api_key = "zdWedlYa0U8CeAAcw8Jkb1IOeFGzsWMHOyPvIFAL"
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
                await loadData()
            }
        }
    }
    
    // modify this to be a global func that takes an api key, data to save at and url to take from
    func loadData() async {
        guard let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=\(api_key)") else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(APOD.self, from: data)
            apod = decodedResponse
        } catch {
            print("Invalid data")
        }
    }
}

#Preview {
    APODView()
}


