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
    @Query(sort: \NamedPhoto.name) private var namedPhotos: [NamedPhoto]
    @State private var viewModel = ContentViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                PhotoListView(namedPhotos: namedPhotos, onDelete: { photo in
                    viewModel.deletePhoto(photo, modelContext: modelContext)
                })
            }
            .navigationTitle("NameSnap")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.startAddingPhoto()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.isAddingPhoto) {
                AddPhotoView(
                    selectedItem: $viewModel.selectedItem,
                    imageData: $viewModel.imageData,
                    processedImage: $viewModel.processedImage,
                    photoName: $viewModel.photoName,
                    onSave: { location in
                        viewModel.savePhoto(location: location, modelContext: modelContext)
                    },
                    onCancel: {
                        viewModel.cancelAddingPhoto()
                    }
                )
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }
}



#Preview {
    ContentView()
}










