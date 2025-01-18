//
//  PhotoListView.swift
//  NameSnap
//
//  Created by Saydulayev on 15.01.25.
//

import SwiftUI

struct PhotoListView: View {
    let namedPhotos: [NamedPhoto]
    let onDelete: (NamedPhoto) -> Void

    @State private var photoToDelete: NamedPhoto?
    @State private var showConfirmationDialog = false
    @State private var searchText = ""

    /// Отфильтрованный и отсортированный список
    var filteredPhotos: [NamedPhoto] {
        let filtered = namedPhotos.filter { photo in
            searchText.isEmpty || photo.name.localizedCaseInsensitiveContains(searchText)
        }
        return filtered.sorted()
    }

    /// Вспомогательный метод для отображения строки списка
    private func photoRow(for photo: NamedPhoto) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                // Отображение изображения
                if let uiImage = UIImage(data: photo.photo) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 3)
                }

                // Основной текстовый блок
                VStack(alignment: .leading, spacing: 4) {
                    Text(photo.name)
                        .font(.headline)

                    // Дата добавления
                    Text("Added: \(photo.dateAdded, style: .date)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Город или fallback, если он отсутствует
                    if let city = photo.city {
                        Text("City: \(city)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    } else {
                        Text("City: Location not available")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
                Spacer()
            }

            Rectangle()
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .foregroundColor(.gray.opacity(0.2))
        }
        .padding(.vertical, 8)
    }


    var body: some View {
        VStack {
            TextField("Search photos", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            List {
                Section(header: Text("Saved Photos")
                    .font(.headline)
                    .foregroundStyle(.gray)
                ) {
                    ForEach(filteredPhotos) { photo in
                        NavigationLink(destination: DetailView(photo: photo)) {
                            photoRow(for: photo)
                        }
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                photoToDelete = photo
                                showConfirmationDialog = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .confirmationDialog(
            "Are you sure you want to delete this photo?",
            isPresented: $showConfirmationDialog,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let photoToDelete {
                    onDelete(photoToDelete)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}



#Preview {
    let samplePhotos = [
        NamedPhoto(name: "Beach", photo: UIImage(systemName: "photo")!.jpegData(compressionQuality: 1.0)!),
        NamedPhoto(name: "Mountain", photo: UIImage(systemName: "photo")!.jpegData(compressionQuality: 1.0)!),
        NamedPhoto(name: "City", photo: UIImage(systemName: "photo")!.jpegData(compressionQuality: 1.0)!)
    ]
    
    PhotoListView(
        namedPhotos: samplePhotos,
        onDelete: { _ in }
    )
}
