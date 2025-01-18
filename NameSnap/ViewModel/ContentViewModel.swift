//
//  ContentViewModel.swift
//  NameSnap
//
//  Created by Saydulayev on 18.01.25.
//

import SwiftUI
import SwiftData
import CoreLocation  
import PhotosUI

@Observable
final class ContentViewModel {
    private let locationFetcher = LocationFetcher()
    private let geocoder = CLGeocoder()

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

            let newPhoto = NamedPhoto(name: photoName, photo: imageData, latitude: location?.latitude, longitude: location?.longitude)

            // Обратное геокодирование для определения города
            if let location = location {
                let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
                    if let placemark = placemarks?.first, error == nil {
                        newPhoto.city = placemark.locality // Название города
                    }
                    modelContext.insert(newPhoto)
                    try? modelContext.save()
                }
            } else {
                modelContext.insert(newPhoto)
                try? modelContext.save()
            }

            resetPhotoState()
        }

    /// Удаляет указанное фото
    func deletePhoto(_ photo: NamedPhoto, modelContext: ModelContext) {
        withAnimation {
            modelContext.delete(photo)
            do {
                try modelContext.save()
            } catch {
                print("Failed to save deletion: \(error)")
            }
        }
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

