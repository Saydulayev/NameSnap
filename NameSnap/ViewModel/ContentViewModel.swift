//
//  ContentViewModel.swift
//  NameSnap
//
//  Created by Saydulayev on 18.01.25.
//

import SwiftUI
import PhotosUI
import SwiftData



@Observable
final class ContentViewModel {
    private let locationFetcher = LocationFetcher()

    // Данные для добавления нового фото
    var selectedItem: PhotosPickerItem?
    var imageData: Data?
    var processedImage: Image?
    var errorMessage: String?
    var photoName: String = ""
    var isAddingPhoto: Bool = false

    // MARK: - Методы

    /// Запускает добавление нового фото
    func startAddingPhoto() {
        locationFetcher.start()
        isAddingPhoto = true
    }

    /// Обрабатывает сохранение нового фото
    func savePhoto(location: CLLocationCoordinate2D?, modelContext: ModelContext) {
        guard let imageData = imageData else {
            errorMessage = "Please select a valid image."
            return
        }

        let newPhoto = NamedPhoto(
            name: photoName,
            photo: imageData,
            latitude: location?.latitude,
            longitude: location?.longitude
        )
        modelContext.insert(newPhoto)
        resetPhotoState()
    }

    /// Удаляет указанное фото
    func deletePhoto(_ photo: NamedPhoto, modelContext: ModelContext) {
        modelContext.delete(photo)
    }

    /// Сбрасывает состояние добавления фото
    func cancelAddingPhoto() {
        resetPhotoState()
    }

    /// Сбрасывает все временные данные
    private func resetPhotoState() {
        selectedItem = nil
        imageData = nil
        processedImage = nil
        photoName = ""
        isAddingPhoto = false
    }
}
