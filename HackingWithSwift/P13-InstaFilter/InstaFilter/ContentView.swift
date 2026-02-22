//
//  ContentView.swift
//  InstaFilter
//
//  Created by Michael Gillbanks on 21/02/2026.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import StoreKit
import SwiftUI

struct ContentView: View {
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var radiusAmount = 0.5
    @State private var scaleAmount = 0.5
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingFilters = false
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                PhotosPicker(selection: $selectedItem) {
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView("No Picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedItem, loadImage)
                
                Spacer()
                
                VStack {
                    HStack {
                        Text("Intensity")
                            .frame(width: 70)
                        Slider(value: $filterIntensity)
                    }
                    .disabled(processedImage == nil)
                    .onChange(of: filterIntensity, applyProcessing)
                    
                    HStack {
                        Text("Radius")
                            .frame(width: 70)
                        Slider(value: $radiusAmount)
                    }
                    .disabled(processedImage == nil)
                    .onChange(of: radiusAmount, applyProcessing)
                    
                    HStack {
                        Text("Scale")
                            .frame(width: 70)
                        Slider(value: $scaleAmount)
                    }
                    .disabled(processedImage == nil)
                    .onChange(of: scaleAmount, applyProcessing)
                }
                
                HStack {
                    Button("Change Filter", action: changeFilter)
                        .confirmationDialog("Select a filter", isPresented: $showingFilters) {
                            ScrollView {
                                Button("Crystalize") { setFilter(CIFilter.crystallize())}
                                Button("Edges") { setFilter(CIFilter.edges())}
                                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur())}
                                Button("Pixellate") { setFilter(CIFilter.pixellate())}
                                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone())}
                                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask())}
                                Button("Vignette") { setFilter(CIFilter.vignette())}
                                Button("Invert Colours") { setFilter(CIFilter.colorInvert())}
                                Button("Depth Of Field") { setFilter(CIFilter.depthOfField())}
                                Button("Kaleidoscope") { setFilter(CIFilter.kaleidoscope())}
                                Button("Cancel", role: .cancel) { }
                            }
                        }
                        .disabled(processedImage == nil)
                    Spacer()
                    
                    if let processedImage {
                        ShareLink(item: processedImage, preview: SharePreview("Instafilter image", image: processedImage))
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
        }
    }
    
    func changeFilter() {
        showingFilters = true
    }
    
    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            
            guard let inputImage = UIImage(data: imageData) else { return }
            
            let beingImage = CIImage(image: inputImage)
            currentFilter.setValue(beingImage, forKey: kCIInputImageKey)
            applyProcessing()
        }
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(radiusAmount*200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(scaleAmount*50, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
    
    @MainActor func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
        
        filterCount += 1
        if filterCount >= 20 {
            requestReview()
        }
    }
}

#Preview {
    ContentView()
}
