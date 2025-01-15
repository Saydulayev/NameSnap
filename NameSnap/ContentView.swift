//
//  ContentView.swift
//  NameSnap
//
//  Created by Saydulayev on 14.01.25.
//

import SwiftUI
import PhotosUI
import SwiftData

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
                    VStack(spacing: 16) {
                        processedImage
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                            .padding(.horizontal)
                        
                        TextField("Enter photo name", text: $photoName)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                        
                        Button(action: savePhoto) {
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

                Spacer()
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                List {
                    Section(header: Text("Saved Photos").font(.headline).foregroundStyle(.gray)) {
                        ForEach(namedPhotos) { photo in
                            NavigationLink(destination: DetailView(photo: photo)) {
                                VStack {
                                    HStack(spacing: 16) {
                                        if let uiImage = UIImage(data: photo.photo) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 64, height: 64)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .shadow(radius: 3)
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(photo.name)
                                                .font(.headline)
                                                .foregroundStyle(.primary)
                                            Text("Tap to see details")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .frame(maxHeight: 80)
                                    .padding(.vertical, 8)
                                    Rectangle()
                                        .frame(height: 1)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.gray.opacity(0.2))
                                }
                            }
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deletePhoto(photo)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .frame(width: 64, height: 64) // Совпадает с размером изображения
                                        .background(Color.red)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)


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



struct DetailView: View {
    let photo: NamedPhoto

    var body: some View {
        VStack {
            if let uiImage = UIImage(data: photo.photo) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .padding()
            }
            Text(photo.name)
                .font(.title)
                .padding()
            Spacer()
        }
        .navigationTitle("Photo Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}


extension Image {
    func missionImageViewStyle() -> some View {
        self
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white, lineWidth: 1)
            )
            .padding(5)
            .shadow(color: .black, radius: 5)
            .frame(width: 100, height: 100)
    }
}
