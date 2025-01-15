//
//  PhotoInputSection.swift
//  NameSnap
//
//  Created by Saydulayev on 15.01.25.
//

import SwiftUI

struct PhotoInputSection: View {
    let processedImage: Image
    @Binding var photoName: String
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            processedImage
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 4)
                .padding(.horizontal)
            
            TextField("Enter photo name", text: $photoName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Button(action: onSave) {
                Label("Save Photo", systemImage: "tray.and.arrow.down.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @State var photoName = "Sample Photo"
    PhotoInputSection(
        processedImage: Image(systemName: "photo"),
        photoName: $photoName,
        onSave: {}
    )
}
