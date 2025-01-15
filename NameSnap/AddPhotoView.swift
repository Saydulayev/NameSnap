//
//  AddPhotoView.swift
//  NameSnap
//
//  Created by Saydulayev on 15.01.25.
//

import SwiftUI
import PhotosUI

struct AddPhotoView: View {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var imageData: Data?
    @Binding var processedImage: Image?
    @Binding var photoName: String
    let onSave: () -> Void
    let onCancel: () -> Void
    let loadImage: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let processedImage {
                    processedImage
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)
                        .padding(.horizontal)
                }

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Select Photo", systemImage: "photo.on.rectangle")
                        .foregroundColor(.blue)
                        .padding()
                }
                .onChange(of: selectedItem, loadImage)

                TextField("Enter photo name", text: $photoName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                HStack {
                    Button(action: onSave) {
                        Label("Save", systemImage: "tray.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(photoName.isEmpty)
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)

                    Button(action: onCancel) {
                        Label("Cancel", systemImage: "xmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Add Photo")
        }
    }
}

#Preview {
    @Previewable @State var selectedItem: PhotosPickerItem? = nil
    @Previewable @State var imageData: Data? = nil
    @Previewable @State var processedImage: Image? = nil
    @Previewable @State var photoName: String = ""

    return AddPhotoView(
        selectedItem: $selectedItem,
        imageData: $imageData,
        processedImage: $processedImage,
        photoName: $photoName,
        onSave: {
            print("Photo saved with name: \(photoName)")
        },
        onCancel: {
            print("Add photo cancelled")
        },
        loadImage: {
            print("Image loading triggered")
        }
    )
}

