//
//  HorizontalBar.swift
//  Moonshot
//
//  Created by Michael Gillbanks on 06/02/2026.
//

import SwiftUI

struct HorizontalBar: View {
    var body: some View {
        Rectangle()
            .frame(height: 2)
            .foregroundStyle(.lightBackground)
            .padding(.vertical)
    }
}

#Preview {
    HorizontalBar()
}


