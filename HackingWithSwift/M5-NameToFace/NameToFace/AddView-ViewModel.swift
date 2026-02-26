//
//  AddView-ViewModel.swift
//  NameToFace
//
//  Created by Michael Gillbanks on 26/02/2026.
//

import PhotosUI
import SwiftUI
import SwiftData

extension AddView {
    @Observable
    class ViewModel {
        let locationFetcher = LocationFetcher()
        var imageData: Data = Data()
        var processedImage: Image?
        var selectedItem: PhotosPickerItem?

        var name: String = ""
        var notes: String = ""
        var addLocation: Bool = false
        
        var location: CLLocationCoordinate2D? {
            addLocation ? locationFetcher.lastKnownLocation : nil
        }
        
        var latitude: Double?
        var longitude: Double?
        
        func loadImage() {
            Task {
                guard let data = try await selectedItem?.loadTransferable(type: Data.self) else { return }
                imageData = data

                guard let inputImage = UIImage(data: data) else { return }
                processedImage = Image(uiImage: inputImage)
            }
        }
        
        func savePerson(using modelContext: ModelContext) {
            guard !imageData.isEmpty else { return }
            
            guard !name.isEmpty else { return }
            
            if location != nil {
                print("Location saved.")
            }
            
            let newPerson = Person(photo: imageData, name: name, notes: notes, latitude: location?.latitude, longitude: location?.longitude)
            modelContext.insert(newPerson)
            
            do {
                try modelContext.save()
            } catch {
                print ("Failed to save person.")
            }
            print("Person added.")
            locationFetcher.stop()
        }
        
        func handleLocationToggle(_ enabled: Bool) {
            if enabled {
                locationFetcher.start()
            } else {
                locationFetcher.stop()
            }
        }
    }
}
