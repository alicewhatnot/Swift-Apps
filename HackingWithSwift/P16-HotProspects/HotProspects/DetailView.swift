//
//  detailView.swift
//  HotProspects
//
//  Created by Michael Gillbanks on 27/02/2026.
//

import SwiftData
import SwiftUI

struct DetailView: View {
    @Environment(\.dismiss) var dismiss
    
    @Bindable var prospect: Prospect   
    
    var body: some View {
        Form {
            TextField("Name", text: $prospect.name)
            TextField("Email Address", text: $prospect.emailAddress)
        }
        .navigationTitle("Alter Prospect")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    dismiss()
                }
            }
        }
    }
    
    
    init(for prospect: Prospect) {
        self.prospect = prospect
    }
}

