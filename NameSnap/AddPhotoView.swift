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
                // 1. Кнопка выбора фото
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Select Photo", systemImage: "photo.on.rectangle")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .onChange(of: selectedItem, loadImage)
                .padding(.top, 32)

                // 2. Если фото уже выбрано, показываем PhotoInputSection,
                //    иначе можно вывести Placeholder, текст или иконку
                if let processedImage {
                    PhotoInputSection(
                        processedImage: processedImage,
                        photoName: $photoName,
                        onSave: onSave,
                        onCancel: onCancel
                    )
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.artframe")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No photo selected")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
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

