//
//  AddView.swift
//  NameToFace
//
//  Created by Michael Gillbanks on 25/02/2026.
//

import PhotosUI
import SwiftUI
import SwiftData

struct AddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $viewModel.selectedItem) {
                            if let image = viewModel.processedImage {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 300, height: 300)
                                    .clipped()
                                    .cornerRadius(15)
                                    .accessibilityLabel("Selected photo")
                            } else {
                                ContentUnavailableView("No Picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                                    .frame(width: 300, height: 300)
                            }
                        }
                        .buttonStyle(.plain)
                        .onChange(of: viewModel.selectedItem, viewModel.loadImage)
                        Spacer()
                    }
                }
                Section("Details") {
                    TextField("Name", text: $viewModel.name)
                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)
                    Toggle("Add Location", isOn: $viewModel.addLocation)
                        .onChange(of: viewModel.addLocation) { _, newValue in
                            viewModel.handleLocationToggle(newValue)
                        }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) { 
                    Button("Save") {
                        viewModel.savePerson(using: modelContext)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Add Face")
        }
    }
}

#Preview {
    AddView()
}
