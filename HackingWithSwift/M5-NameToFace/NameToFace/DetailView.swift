//
//  DetailView.swift
//  NameToFace
//
//  Created by Michael Gillbanks on 25/02/2026.
//

import MapKit
import SwiftUI

struct DetailView: View {
    var person: Person
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        List {
            Section {
                if let uiImage = person.uiImage {
                    HStack {
                        Spacer()
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 300)
                            .clipped()
                            .cornerRadius(15)
                            .accessibilityLabel("Photo of \(person.name)")
                        Spacer()
                    }
                }
            }
            
            Section("Notes") {
                Text(person.notes != "" ? person.notes : "No Notes.")
            }
            
            if let lat = person.latitude, let lon = person.longitude {
                Section("Map") {
                    let startPosition = MapCameraPosition.region(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
                        ))
                    Map(initialPosition: startPosition) {
                        Marker("Location", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                    }
                    .frame(height: 300)
                    .cornerRadius(15)
                    .accessibilityLabel("Map showing location where this person was added")
                }
            }
        }
        .navigationTitle(person.name)
        .scrollBounceBehavior(.basedOnSize)
    }
}
