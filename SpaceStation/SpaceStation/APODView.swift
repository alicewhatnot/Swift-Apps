//
//  APODView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 08/03/2026.
//

import SwiftUI
import SwiftData
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView { WKWebView() }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}

struct APODView: View {
    @Environment(\.API_KEY) var api_key
    @Environment(\.modelContext) var modelContext
    @Query private var cachedAPODs: [CachedAPOD]

    @State private var apod = APOD.placeholder
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(apod.title)
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                ZStack(alignment: .topLeading) {
                    if apod.media_type == "video", let url = apod.decodedUrl {
                        WebView(url: url)
                            .frame(height: 220)
                            .cornerRadius(20)
                            .padding(.top)
                    } else {
                        AsyncImage(url: apod.decodedUrl) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .symbolRenderingMode(.hierarchical)
                                    .padding()
                                    .opacity(0.6)
                                if isLoading { ProgressView() }
                            }
                            .frame(height: 200)
                        }
                        .frame(maxWidth: .infinity)
                        .cornerRadius(20)
                        .padding(.top)
                        .clipped()
                    }

                    if let copyright = apod.copyright {
                        Text("CC: \(copyright)")
                            .font(.caption2)
                            .background(.secondary.opacity(0.5))
                            .foregroundStyle(.white)
                            .offset(x: 5, y: 10)
                    }
                }

                Text(apod.explanation)
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
                    .padding()
            }
            .defaultBackground()
            .preferredColorScheme(.dark)
            .navigationTitle("Picture of the Day")
            .task { await loadAPOD() }
            .refreshable { await refreshFromNetwork() }
        }
    }

    func loadAPOD() async {
        let todayString = {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            return f.string(from: .now)
        }()

        if let cached = cachedAPODs.first,
           cached.apodDate == todayString,
           !cached.isStale,
           let decoded = try? JSONDecoder().decode(APOD.self, from: cached.jsonData) {
            apod = decoded
            isLoading = false
        } else {
            await refreshFromNetwork()
        }
    }

    func refreshFromNetwork() async {
        do {
            apod = try await CacheService.fetchAndCacheAPOD(
                apiKey: api_key,
                context: modelContext
            )
        } catch {
            print("Failed to load APOD:", error)
        }
        isLoading = false
    }
}

#Preview {
    APODView()
}
