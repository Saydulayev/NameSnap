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

    let onSave: (CLLocationCoordinate2D?) -> Void
    let onCancel: () -> Void
    let loadImage: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Select Photo", systemImage: "photo.on.rectangle")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .onChange(of: selectedItem, loadImage)
                .padding(.top, 32)

                if let processedImage {
                    processedImage
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
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

                TextField("Enter photo name", text: $photoName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                TextField("Enter address (optional)", text: $address)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                HStack {
                    Button("Use Address") {
                        geocodeAddress()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(address.isEmpty)

                    Button("Pick Location on Map") {
                        showMapPicker = true
                    }
                    .buttonStyle(.bordered)
                }

                if let selectedLocation {
                    Text("Selected Location: \(selectedLocation.latitude), \(selectedLocation.longitude)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Button(action: {
                        onSave(selectedLocation)
                        resetStates() // Сбрасываем состояния после сохранения
                    }) {
                        Label("Save Photo", systemImage: "tray.and.arrow.down.fill")
                    }
                    .disabled(photoName.isEmpty)
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)

                    Button(action: {
                        onCancel()
                        resetStates() // Сбрасываем состояния после отмены
                    }) {
                        Label("Cancel", systemImage: "xmark.circle")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Add Photo")
            .sheet(isPresented: $showMapPicker) {
                MapPickerView(
                    region: $region,
                    selectedLocation: $selectedLocation
                )
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

    private func geocodeAddress() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                errorMessage = "Failed to find location: \(error.localizedDescription)"
                return
            }

            if let placemark = placemarks?.first, let location = placemark.location {
                selectedLocation = location.coordinate
                region.center = location.coordinate
            } else {
                errorMessage = "Location not found"
            }
        }
    }

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
    }
}




struct MapPickerView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedLocation: CLLocationCoordinate2D?

    var body: some View {
        NavigationStack {
            Map(initialPosition: .region(region)) {
                if let selectedLocation {
                    Annotation("", coordinate: selectedLocation) {
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.red)
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .onTapGesture {
                selectedLocation = region.center
            }
            .navigationTitle("Pick Location")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        selectedLocation = region.center
                    }
                }
            }
        }
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
        },
        loadImage: {
            print("Image loading triggered")
        }
    )
}

