//
//  ContentView.swift
//  BucketList
//
//  Created by Michael Gillbanks on 23/02/2026.
//

import MapKit
import SwiftUI

struct ContentView: View {
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 55, longitude: -3),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        ))
    
    @State private var viewModel = ViewModel()
    
    enum MapMode {
        case standard, hybrid
    }
    
    @State private var mapMode: MapMode = .standard
        
    var body: some View {
        Group {
            if viewModel.isUnlocked {
                ZStack {
                    MapReader { proxy in
                        Map(initialPosition: startPosition) {
                            ForEach(viewModel.locations) { location in
                                Annotation(location.name, coordinate: location.coordinate) {
                                    Image(systemName: "star.circle")
                                        .resizable()
                                        .foregroundStyle(.red)
                                        .frame(width: 44, height: 44)
                                        .background(.white)
                                        .clipShape(.circle)
                                        .onLongPressGesture(minimumDuration: 0.1) {
                                            viewModel.selectedPlace = location
                                        }
                                }
                            }
                        }
                        .mapStyle(mapMode == .standard ? .standard : .hybrid)
                        .onTapGesture { position in
                            if let coordinate = proxy.convert(position, from: .local) {
                                viewModel.addLocation(at: coordinate)
                            }
                        }
                        .sheet(item: $viewModel.selectedPlace) { place in
                            EditView(location: place) {
                                viewModel.update(location: $0)
                            }
                        }
                    }
                    VStack {
                        Spacer()
                        
                        Button {
                            if mapMode == .standard {
                                mapMode = .hybrid
                            } else {
                                mapMode = .standard
                            }
                        } label: {
                            Text(mapMode == .standard ? "Showing Standard" : "Showing Hybrid")
                        }
                        .padding()
                        .background(.white.opacity(0.5))
                        .foregroundStyle(.primary)
                        .clipShape(.capsule)
                    }
                }
            }
            else {
                Button("Unlock Places", action: viewModel.authenticate)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
            }
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.showingAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

#Preview {
    ContentView()
}
