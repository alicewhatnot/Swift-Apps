//
//  NearEarthObjectDetailView.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 14/03/2026.
//

import SwiftUI

struct NearEarthObjectDetailView: View {
    let asteroid: NearEarthObject
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        let approach = asteroid.close_approach_data.first

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Header card
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text(asteroid.name)
                            .font(.title2.bold())
                        Spacer()
                        if asteroid.is_potentially_hazardous_asteroid {
                            Text("⚠️ Hazardous")
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.orange.opacity(0.25))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        } else {
                            Text("Low Risk")
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.green.opacity(0.2))
                                .foregroundStyle(.green)
                                .clipShape(Capsule())
                        }
                    }

                    if let timeToApproach = approach?.timeToApproach {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .accessibilityHidden(true)
                            Text("Closest approach in \(timeToApproach)")
                                .font(.caption)
                        }
                        .foregroundStyle(.primary.opacity(0.75))
                    }
                }
                .padding()
                .background(.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(headerAccessibilityLabel(asteroid: asteroid, approach: approach))

                // Miss distance bar
                if let dist = approach?.missDistanceKM {
                    SectionCard(title: "Miss Distance", systemImage: "arrow.left.and.right") {
                        MissDistanceBar(missDistanceKM: dist)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(missDistanceAccessibilityLabel(dist: dist, approach: approach))
                }

                // Close approach
                if let approach {
                    SectionCard(title: "Close Approach", systemImage: "dot.scope") {
                        InfoRow(label: "Date", value: approach.formattedApproachDate())
                        if let dist = approach.missDistanceKM {
                            InfoRow(label: "Miss Distance", value: "\(Int(dist).formatted()) km")
                        }
                        let auValue = Double(approach.miss_distance.astronomical) ?? 0
                        InfoRow(label: "", value: String(format: "%.4f AU", auValue))
                        if let vel = approach.velocityKMPerSecond {
                            InfoRow(label: "Velocity", value: "\(Int(vel)) km/s")
                        }
                        InfoRow(label: "Orbiting", value: approach.orbiting_body)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(closeApproachAccessibilityLabel(approach: approach))
                }

                // Physical characteristics
                SectionCard(title: "Physical Characteristics", systemImage: "circle.dotted") {
                    InfoRow(label: "Diameter",
                            value: String(format: "~%.3f km (%.0f–%.0f m)",
                                         asteroid.diameterKM,
                                         asteroid.estimated_diameter.kilometers.estimated_diameter_min * 1000,
                                         asteroid.estimated_diameter.kilometers.estimated_diameter_max * 1000))
                    InfoRow(label: "Magnitude", value: String(format: "H = %.1f", asteroid.absolute_magnitude_h))
                    InfoRow(label: "Size class", value: sizeClass(asteroid.diameterKM))
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(physicalCharacteristicsAccessibilityLabel(asteroid: asteroid))

                // Orbital data
                if let orbital = asteroid.orbital_data,
                   let firstObserved = orbital.first_observation_date {
                    SectionCard(title: "Orbital Data", systemImage: "arrow.clockwise.circle") {
                        InfoRow(label: "First Observed", value: firstObserved)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Orbital data, first observed \(firstObserved)")
                }

                // All approach dates if there are multiple
                if asteroid.close_approach_data.count > 1 {
                    SectionCard(title: "All Approaches (\(asteroid.close_approach_data.count))",
                                systemImage: "calendar") {
                        VStack(spacing: 8) {
                            ForEach(Array(asteroid.close_approach_data.prefix(8).enumerated()), id: \.offset) { index, ca in
                                HStack {
                                    Circle()
                                        .fill(index == 0 ? Color.blue : .secondary.opacity(0.4))
                                        .frame(width: 7, height: 7)
                                        .accessibilityHidden(true)
                                    Text(ca.formattedApproachDate())
                                        .font(.subheadline)
                                    Spacer()
                                    if let dist = ca.missDistanceKM {
                                        Text("\(Int(dist).formatted()) km")
                                            .font(.caption.monospacedDigit())
                                            .foregroundStyle(.primary.opacity(0.75))
                                    }
                                }
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel({
                                    var label = index == 0 ? "Nearest: " : ""
                                    label += ca.formattedApproachDate()
                                    if let dist = ca.missDistanceKM {
                                        label += ", miss distance \(Int(dist).formatted()) kilometres"
                                    }
                                    return label
                                }())
                            }
                            if asteroid.close_approach_data.count > 8 {
                                Text("+ \(asteroid.close_approach_data.count - 8) more")
                                    .font(.caption)
                                    .foregroundStyle(.primary.opacity(0.5))
                                    .accessibilityLabel("\(asteroid.close_approach_data.count - 8) more approaches not shown")
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Asteroid Detail")
        .navigationBarTitleDisplayMode(.inline)
        .defaultBackground(reduceMotion: reduceMotion)
        .preferredColorScheme(.dark)
    }

    // MARK: - Accessibility label helpers

    func headerAccessibilityLabel(asteroid: NearEarthObject, approach: CloseApproach?) -> String {
        var parts = [asteroid.name]
        parts.append(asteroid.is_potentially_hazardous_asteroid ? "potentially hazardous" : "low risk")
        if let timeToApproach = approach?.timeToApproach {
            parts.append("closest approach in \(timeToApproach)")
        }
        return parts.joined(separator: ", ")
    }

    func missDistanceAccessibilityLabel(dist: Double, approach: CloseApproach?) -> String {
        var parts = ["Miss distance \(Int(dist).formatted()) kilometres"]
        let auValue = Double(approach?.miss_distance.astronomical ?? "0") ?? 0
        parts.append(String(format: "%.4f astronomical units", auValue))
        return parts.joined(separator: ", ")
    }

    func closeApproachAccessibilityLabel(approach: CloseApproach) -> String {
        var parts = ["Close approach", "date \(approach.formattedApproachDate())"]
        if let dist = approach.missDistanceKM {
            parts.append("miss distance \(Int(dist).formatted()) kilometres")
        }
        if let vel = approach.velocityKMPerSecond {
            parts.append("velocity \(Int(vel)) kilometres per second")
        }
        parts.append("orbiting \(approach.orbiting_body)")
        return parts.joined(separator: ", ")
    }

    func physicalCharacteristicsAccessibilityLabel(asteroid: NearEarthObject) -> String {
        let minM = Int(asteroid.estimated_diameter.kilometers.estimated_diameter_min * 1000)
        let maxM = Int(asteroid.estimated_diameter.kilometers.estimated_diameter_max * 1000)
        return [
            "Physical characteristics",
            String(format: "diameter approximately %.3f kilometres, between \(minM) and \(maxM) metres", asteroid.diameterKM),
            String(format: "absolute magnitude H equals %.1f", asteroid.absolute_magnitude_h),
            "size class \(sizeClass(asteroid.diameterKM))"
        ].joined(separator: ", ")
    }

    func sizeClass(_ km: Double) -> String {
        switch km {
        case ..<0.025:  return "Small (car-sized)"
        case ..<0.1:    return "Medium (house-sized)"
        case ..<0.5:    return "Large (stadium-sized)"
        case ..<1.0:    return "Very Large (city block)"
        case ..<5.0:    return "Massive (city-sized)"
        default:        return "Extinction-class"
        }
    }
}

// MARK: - Miss Distance Bar

struct MissDistanceBar: View {
    let missDistanceKM: Double

    static let maxKM:             Double = 75_000_000
    static let lunarDistanceKM:   Double = 384_400
    static let hazardThresholdKM: Double = 7_480_000

    var fraction: Double {
        let linear = max(0, min(1, missDistanceKM / Self.maxKM))
        return sqrt(linear)
    }

    var proximityLabel: String {
        switch missDistanceKM {
        case ..<Self.lunarDistanceKM:    return "Within lunar distance"
        case ..<Self.hazardThresholdKM:  return "Within hazard threshold"
        case ..<20_000_000:              return "Close pass"
        case ..<40_000_000:              return "Moderate pass"
        default:                         return "Distant pass"
        }
    }

    var markerColor: Color {
        switch missDistanceKM {
        case ..<Self.lunarDistanceKM:    return .red
        case ..<Self.hazardThresholdKM:  return .orange
        case ..<20_000_000:              return .yellow
        default:                         return .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack(alignment: .firstTextBaseline) {
                Text("\(Int(missDistanceKM).formatted()) km")
                    .font(.title3.bold())
                    .foregroundStyle(markerColor)
                Spacer()
                Text(proximityLabel)
                    .font(.caption)
                    .foregroundStyle(.primary.opacity(0.75))
            }

            GeometryReader { geo in
                let trackWidth = geo.size.width
                let markerX   = trackWidth * fraction
                let hazardX   = trackWidth * sqrt(Self.hazardThresholdKM / Self.maxKM)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.08))
                        .frame(height: 6)

                    Capsule()
                        .fill(LinearGradient(
                            colors: [.red, .orange, .yellow, .green],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: markerX, height: 6)
                        .animation(.easeOut(duration: 0.9), value: fraction)

                    Rectangle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 1.5, height: 16)
                        .offset(x: hazardX - 0.75, y: -5)

                    Image(systemName: "diamond.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(markerColor)
                        .offset(x: markerX - 5, y: -13)
                        .animation(.easeOut(duration: 0.9), value: fraction)
                }
            }
            .frame(height: 32)
            .accessibilityHidden(true) // distance spoken by parent SectionCard label

            HStack {
                Text("Earth")
                    .font(.caption2)
                    .foregroundStyle(.primary.opacity(0.4))
                Spacer()
                Text("⚠️ 0.05 AU")
                    .font(.caption2)
                    .foregroundStyle(.primary.opacity(0.4))
                Spacer()
                Spacer()
                Spacer()
                Text("0.5 AU")
                    .font(.caption2)
                    .foregroundStyle(.primary.opacity(0.4))
            }
            .accessibilityHidden(true) // scale labels are visual context only
        }
    }
}

#Preview {
    NavigationStack {
        NearEarthObjectDetailView(asteroid: NearEarthObject(
            id: "54016239",
            name: "(2021 QM1)",
            absolute_magnitude_h: 23.7,
            estimated_diameter: EstimatedDiameter(
                kilometers: DiameterRange(
                    estimated_diameter_min: 0.0451,
                    estimated_diameter_max: 0.1009
                )
            ),
            is_potentially_hazardous_asteroid: true,
            close_approach_data: [
                CloseApproach(
                    close_approach_date: "2026-04-02",
                    close_approach_date_full: "2026-Apr-02 14:22",
                    epoch_date_close_approach: 1743602520000,
                    relative_velocity: RelativeVelocity(kilometers_per_second: "18.5"),
                    miss_distance: MissDistance(astronomical: "0.0312", kilometers: "4669320"),
                    orbiting_body: "Earth"
                )
            ],
            orbital_data: OrbitalData(first_observation_date: "2021-08-28")
        ))
    }
}
