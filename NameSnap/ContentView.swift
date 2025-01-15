//
//  ContentView.swift
//  NameSnap
//
//  Created by Saydulayev on 14.01.25.
//

import SwiftUI
import PhotosUI
import SwiftData


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var processedImage: Image?
    @State private var errorMessage: String?
    @State private var photoName: String = ""
    @Query(sort: \NamedPhoto.name) private var namedPhotos: [NamedPhoto]

    var body: some View {
        NavigationStack {
            VStack {
                if let processedImage {
                    PhotoInputSection(
                        processedImage: processedImage,
                        photoName: $photoName,
                        onSave: savePhoto
                    )
                }

                Spacer()

                PhotoListView(
                    namedPhotos: namedPhotos,
                    onDelete: deletePhoto
                )
            }
            .navigationTitle("NameSnap")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    PhotoPickerView(
                        selectedItem: $selectedItem,
                        imageData: $imageData,
                        errorMessage: $errorMessage,
                        loadImage: loadImage
                    )
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK", role: .cancel) {
                    errorMessage = nil 
                }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }

    func loadImage() {
        Task {
            do {
                guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else {
                    throw NSError(domain: "ImageSelection", code: 1, userInfo: [NSLocalizedDescriptionKey: "No image data found."])
                }
                self.imageData = imageData
                if let uiImage = UIImage(data: imageData) {
                    processedImage = Image(uiImage: uiImage)
                }
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func savePhoto() {
        guard !photoName.isEmpty, let imageData else { return }
        let newPhoto = NamedPhoto(name: photoName, photo: imageData)
        modelContext.insert(newPhoto)
        photoName = ""
        self.imageData = nil
        processedImage = nil
    }

    func deletePhoto(_ photo: NamedPhoto) {
        modelContext.delete(photo)
    }
}



#Preview {
    ContentView()
}









