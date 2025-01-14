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
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var processedImage: Image?
    @State private var errorMessage: String?
    @State private var photoName: String = ""
    @State private var namedPhotos: [NamedPhoto] = []

    var body: some View {
        NavigationStack {
            VStack {
                if let processedImage {
                    processedImage
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding()

                    TextField("Введите имя для фото", text: $photoName)
                        .textFieldStyle(.roundedBorder)
                        .padding()

                    Button("Сохранить фото") {
                        savePhoto()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                } else {
                    Text("Выберите изображение")
                        .foregroundColor(.secondary)
                }

                Spacer()

                PhotoPickerView(
                    selectedItem: $selectedItem,
                    imageData: $imageData,
                    errorMessage: $errorMessage,
                    loadImage: loadImage
                )
                

                if let errorMessage {
                    Text("Ошибка: \(errorMessage)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                List(namedPhotos.sorted()) { photo in
                    NavigationLink(destination: DetailView(photo: photo)) {
                        HStack {
                            if let uiImage = UIImage(data: photo.photo) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(Circle())
                                    .frame(width: 64, height: 64)
                            }
                            Text(photo.name)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("NameSnap")
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

    private func updateProcessedImage(with data: Data?) {
        guard let data = data, let uiImage = UIImage(data: data) else { return }
        processedImage = Image(uiImage: uiImage)
    }

    func savePhoto() {
        guard !photoName.isEmpty, let imageData else { return }
        let newPhoto = NamedPhoto(name: photoName, photo: imageData)
        namedPhotos.append(newPhoto)
        photoName = ""
        self.imageData = nil
        processedImage = nil
    }
}




struct DetailView: View {
    let photo: NamedPhoto

    var body: some View {
        VStack {
            if let uiImage = UIImage(data: photo.photo) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
            Text(photo.name)
                .font(.title)
                .padding()
            Spacer()
        }
        .navigationTitle("Детали")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}

