//
//  EditPhotoView.swift
//  NameSnap
//
//  Created by Saydulayev on 15.01.25.
//

import SwiftUI
import PhotosUI

struct EditPhotoView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var photo: NamedPhoto
    @State private var newName: String
    @State private var selectedItem: PhotosPickerItem?
    @State private var newImageData: Data?

    init(photo: Binding<NamedPhoto>) {
        self._photo = photo
        self._newName = State(initialValue: photo.wrappedValue.name)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Photo")) {
                    if let newImageData = newImageData, let uiImage = UIImage(data: newImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 5)
                    } else if let uiImage = UIImage(data: photo.photo) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }

                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Replace Photo", systemImage: "photo.on.rectangle.angled")
                            .foregroundColor(.blue)
                            .onChange(of: selectedItem) {
                                loadImage()
                                newImageData = nil
                            }
                    }
                    .onChange(of: selectedItem, loadImage)
                }
                
                Section(header: Text("Name")) {
                    TextField("Photo Name", text: $newName)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .navigationTitle("Edit Photo")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                    .bold()
                    .disabled(newName.isEmpty && newImageData == nil)
                }
            }
        }
    }

    private func loadImage() {
        Task {
            do {
                guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
                newImageData = imageData
            } catch {
                print("Error loading image: \(error.localizedDescription)")
            }
        }
    }

    private func saveChanges() {
        photo.name = newName
        if let newImageData {
            photo.photo = newImageData
        }
    }
}

#Preview {
    
    @Previewable @State var samplePhoto = NamedPhoto(
        name: "Sample Photo",
        photo: UIImage(named: "sample")?.jpegData(compressionQuality: 1.0) ?? Data()
    )
    
    return EditPhotoView(photo: $samplePhoto)
}
