//
//  AddPhotoView.swift
//  NameSnap
//
//  Created by Saydulayev on 15.01.25.
//


import SwiftUI
import PhotosUI
import MapKit
import CoreLocation

struct AddPhotoView: View {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var imageData: Data?
    @Binding var processedImage: Image?
    @Binding var photoName: String
    
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var address: String = ""
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    @State private var showMapPicker = false
    @State private var errorMessage: String?
    
    // для подсказок
    @State private var addressCompleter = AddressSearchCompleter()

    let onSave: (CLLocationCoordinate2D?) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Кнопка выбора фото
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Select Photo", systemImage: "photo.on.rectangle")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    .onChange(of: selectedItem) { _, newItem in
                        guard let newItem else { return }
                        loadImage(from: newItem)
                    }
                    .padding(.top, 32)

                    // Изображение
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
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

                    // Поле ввода названия
                    TextField("Enter photo name", text: $photoName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    // Поле ввода адреса
                    TextField("Enter address (optional)", text: $address)
                        .onChange(of: address) { oldValue, newValue in
                            if newValue.isEmpty {
                                addressCompleter.suggestions = []
                            } else {
                                addressCompleter.updateQuery(newValue)
                            }
                        }
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    // Отображение подсказок под полем адреса
                    // (Вы можете стилизовать по-своему: List, ScrollView, и т.д.)
                    if !addressCompleter.suggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(addressCompleter.suggestions, id: \.title) { suggestion in
                                // Можно объединить title и subtitle,
                                // например "\(suggestion.title), \(suggestion.subtitle)"
                                // Оставляю для примера отдельно
                                HStack {
                                    Text(suggestion.title)
                                        .font(.body)
                                    if !suggestion.subtitle.isEmpty {
                                        Text(", \(suggestion.subtitle)")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .onTapGesture {
                                    // Пользователь выбрал подсказку
                                    address = "\(suggestion.title), \(suggestion.subtitle)"
                                    // теперь делаем геокодирование, чтобы обновить selectedLocation
                                    geocodeAddress()
                                    // Очищаем подсказки
                                    addressCompleter.suggestions = []
                                }
                            }
                        }
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }

                    // Кнопки для определения локации
                    HStack {
                        Button("Use Address") {
                            // Явный вызов геокодирования
                            geocodeAddress()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(address.isEmpty)

                        Button("Pick Location on Map") {
                            showMapPicker = true
                        }
                        .buttonStyle(.bordered)
                    }

                    // Информация о выбранной локации
                    if let selectedLocation {
                        Text("Selected Location: \(selectedLocation.latitude), \(selectedLocation.longitude)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Кнопки сохранения и отмены
                    HStack {
                        Button {
                            onSave(selectedLocation)
                            resetStates()
                        } label: {
                            Label("Save Photo", systemImage: "tray.and.arrow.down.fill")
                        }
                        .disabled(photoName.isEmpty)
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)

                        Button {
                            onCancel()
                            resetStates()
                        } label: {
                            Label("Cancel", systemImage: "xmark.circle")
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Add Photo")
            .sheet(isPresented: $showMapPicker) {
                MapPickerView(
                    region: $region,
                    selectedLocation: $selectedLocation,
                    address: $address
                )
            }
            // Отображение ошибки, если есть
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }

    // Загрузка изображения
    private func loadImage(from item: PhotosPickerItem) {
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    throw NSError(domain: "ImageSelection", code: 1,
                                  userInfo: [NSLocalizedDescriptionKey: "No image data found."])
                }
                imageData = data
                if let uiImage = UIImage(data: data) {
                    processedImage = Image(uiImage: uiImage)
                }
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // Геокодирование введённого адреса
    private func geocodeAddress() {
        guard !address.isEmpty else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                errorMessage = "Failed to find location: \(error.localizedDescription)"
                return
            }
            if let placemark = placemarks?.first,
               let location = placemark.location {
                selectedLocation = location.coordinate
                region.center = location.coordinate
            } else {
                errorMessage = "Location not found"
            }
        }
    }

    // Сброс состояний
    private func resetStates() {
        selectedItem = nil
        imageData = nil
        processedImage = nil
        photoName = ""
        selectedLocation = nil
        address = ""
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        addressCompleter.suggestions = []
    }
}




#Preview {
    @Previewable @State var selectedItem: PhotosPickerItem? = nil
    @Previewable @State var imageData: Data? = nil
    @Previewable @State var processedImage: Image? = nil
    @Previewable @State var photoName: String = ""

    AddPhotoView(
        selectedItem: $selectedItem,
        imageData: $imageData,
        processedImage: $processedImage,
        photoName: $photoName,
        onSave: {_ in 
            print("Photo saved with name: \(photoName)")
        },
        onCancel: {
            print("Add photo cancelled")
        }
    )
}

