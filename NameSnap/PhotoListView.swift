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

    var body: some View {
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
                                }
                                .padding(.horizontal)
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
                            photoToDelete = photo
                            showConfirmationDialog = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .frame(width: 64, height: 64)
                                .background(Color.red)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .confirmationDialog("Are you sure you want to delete this photo?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
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
