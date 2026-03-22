//
//  APODView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 08/03/2026.
//

import SwiftUI
import SwiftData

struct APODView: View {
    @Environment(\.API_KEY) var api_key
    @Environment(\.modelContext) var modelContext
    @Environment(\.accessibilityReduceMotion) var reduceMotion
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
                        YouTubeThumbnailView(url: url)
                            .padding(.top)
                            .accessibilityLabel("Video: \(apod.title). Tap to open in YouTube.")
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
                                    .accessibilityHidden(true)
                                if isLoading { ProgressView() }
                            }
                            .frame(height: 200)
                        }
                        .frame(maxWidth: .infinity)
                        .cornerRadius(20)
                        .padding(.top)
                        .clipped()
                        .accessibilityLabel(apod.copyright != nil ? "Astronomy photo: \(apod.title). Copyright \(apod.copyright!)" : "Astronomy photo: \(apod.title)")
                    }

                    if let copyright = apod.copyright {
                        Text("CC: \(copyright)")
                            .font(.caption2)
                            .background(.secondary.opacity(0.5))
                            .foregroundStyle(.white)
                            .offset(x: 5, y: 10)
                            .accessibilityHidden(true) // spoken as part of image label above
                    }
                }

                Text(apod.explanation)
                    .font(.system(size: 17))
                    .foregroundStyle(.primary.opacity(0.85)) // was .secondary — lifted for contrast
                    .padding()
            }
            .defaultBackground(reduceMotion: reduceMotion)
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

struct YouTubeThumbnailView: View {
    let url: URL

    var videoID: String? {
        let str = url.absoluteString
        if let range = str.range(of: "embed/") {
            let id = str[range.upperBound...]
            return String(id.prefix(while: { $0 != "?" && $0 != "&" }))
        }
        if let range = str.range(of: "youtu.be/") {
            let id = str[range.upperBound...]
            return String(id.prefix(while: { $0 != "?" && $0 != "&" }))
        }
        return nil
    }

    var thumbnailURL: URL? {
        guard let id = videoID else { return nil }
        return URL(string: "https://img.youtube.com/vi/\(id)/hqdefault.jpg")
    }

    var body: some View {
        Button {
            UIApplication.shared.open(url)
        } label: {
            ZStack {
                AsyncImage(url: thumbnailURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(.secondary.opacity(0.2))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipped()
                .cornerRadius(20)
                .accessibilityHidden(true)

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(radius: 10)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    APODView()
}
