//
//  APODView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 08/03/2026.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}

struct APOD: Codable {
    let copyright: String?
    let explanation: String
    let media_type: String
    let title: String
    let url: String

    var decodedUrl: URL? { URL(string: url) }
    static let placeholder = APOD(copyright: nil, explanation: "", media_type: "image", title: "Loading APOD...", url: "")
}

struct APODView: View {
    @Environment(\.API_KEY) var api_key
    @State private var apod = APOD.placeholder
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(apod.title)
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                ZStack(alignment: .bottomLeading) {
                    
                    
                    if apod.media_type == "video", let url = apod.decodedUrl {
                        WebView(url: url)
                            .frame(height: 220)
                            .cornerRadius(20)
                            .padding(.top)
                    } else {
                        AsyncImage(url: apod.decodedUrl) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .symbolRenderingMode(.hierarchical)
                                    .padding()
                                    .opacity(0.6)
                                ProgressView()
                            }
                            .frame(height: 200)
                        }
                        .frame(maxWidth: .infinity)
                        .cornerRadius(20)
                        .padding(.top)
                        .clipped()
                    }
                    
                    if apod.copyright != nil {
                        Text("CC: \(apod.copyright!)")
                            .background(.secondary.opacity(0.5))
                            .foregroundStyle(Color.white)
                            .offset(x: 5, y: -5)
                    }
                }
                Text(apod.explanation)
                    .font(.system(size: 20, weight: .regular, design: .default)).opacity(0.7)
                    .padding()
                
            }
            .background(
                Image("stars")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.5)
            )

            .preferredColorScheme(.dark)
            .navigationTitle("Picture of the Day")
            .task {
                await loadAPOD()
            }
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


