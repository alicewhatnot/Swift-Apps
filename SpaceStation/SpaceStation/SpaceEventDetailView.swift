//
//  SpaceEventDetailView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 22/03/2026.
//

import SwiftUI

struct SpaceEventDetailView: View {
    let event: SpaceEvent
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Header card
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.type)
                                .font(.title2.bold())
                            Text(event.date)
                                .font(.subheadline)
                                .foregroundStyle(.primary.opacity(0.75))
                        }
                        Spacer()
                        if let cls = event.classType {
                            Text(cls)
                                .font(.title3.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(classTypeColor(cls).opacity(0.25))
                                .foregroundStyle(classTypeColor(cls))
                                .clipShape(Capsule())
                                .accessibilityLabel("Class \(cls)")
                        }
                    }
                }
                .padding()
                .background(.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(headerAccessibilityLabel)

                // Timing (flares have begin/peak/end)
                if event.peakTime != nil || event.endTime != nil {
                    SectionCard(title: "Timing", systemImage: "clock") {
                        InfoRow(label: "Begin", value: event.date)
                        if let peak = event.peakTime {
                            InfoRow(label: "Peak", value: peak)
                        }
                        if let end = event.endTime {
                            InfoRow(label: "End", value: end)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(timingAccessibilityLabel)
                }

                // Location
                if event.sourceLocation != nil || event.location != nil {
                    SectionCard(title: "Location", systemImage: "location") {
                        if let src = event.sourceLocation {
                            InfoRow(label: "Source", value: src)
                        }
                        if let loc = event.location {
                            InfoRow(label: "Impact", value: loc)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(locationAccessibilityLabel)
                }

                // Notes
                if !event.detail.isEmpty {
                    SectionCard(title: "Notes", systemImage: "doc.text") {
                        Text(event.detail)
                            .font(.body)
                            .foregroundStyle(.primary.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Notes: \(event.detail)")
                }

                // Source link
                if let link = event.link {
                    SectionCard(title: "Source", systemImage: "link") {
                        Link(destination: link) {
                            HStack {
                                Text("View on NASA DONKI")
                                    .font(.subheadline)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .accessibilityHidden(true)
                            }
                            .foregroundStyle(.blue)
                        }
                        .accessibilityLabel("View on NASA DONKI")
                        .accessibilityHint("Opens in browser")
                        .accessibilityAddTraits(.isLink)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(event.type)
        .navigationBarTitleDisplayMode(.inline)
        .defaultBackground(reduceMotion: reduceMotion)
        .preferredColorScheme(.dark)
    }

    // MARK: - Accessibility label helpers

    var headerAccessibilityLabel: String {
        var parts = [event.type, event.date]
        if let cls = event.classType { parts.append("class \(cls)") }
        return parts.joined(separator: ", ")
    }

    var timingAccessibilityLabel: String {
        var parts = ["Timing", "begins \(event.date)"]
        if let peak = event.peakTime { parts.append("peaks \(peak)") }
        if let end = event.endTime { parts.append("ends \(end)") }
        return parts.joined(separator: ", ")
    }

    var locationAccessibilityLabel: String {
        var parts = ["Location"]
        if let src = event.sourceLocation { parts.append("source \(src)") }
        if let loc = event.location { parts.append("impact \(loc)") }
        return parts.joined(separator: ", ")
    }

    func classTypeColor(_ cls: String) -> Color {
        switch cls.prefix(1).uppercased() {
        case "X": return .red
        case "M": return .orange
        case "C": return .yellow
        default:  return .green
        }
    }
}

// MARK: - Reusable sub-views

struct SectionCard<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(.primary.opacity(0.75))
                .accessibilityHidden(true) // spoken via parent .accessibilityLabel
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.6))
                .frame(width: 70, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        SpaceEventDetailView(event: SpaceEvent(
            id: "preview",
            type: "Solar Flare",
            date: "13 Mar 2026 at 09:40",
            rawDate: "2026-03-13T09:40Z",
            detail: "An M1.1 class flare from active region 14384 located at N10W70.",
            classType: "M1.1",
            sourceLocation: "N10W70",
            peakTime: "13 Mar 2026 at 09:55",
            endTime: "13 Mar 2026 at 10:05",
            location: nil,
            catalog: "M2M_CATALOG",
            link: URL(string: "https://webtools.ccmc.gsfc.nasa.gov/DONKI/view/FLR/45046/-1")
        ))
    }
}
