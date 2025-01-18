//
//  MapPickerView.swift
//  NameSnap
//
//  Created by Saydulayev on 18.01.25.
//

import SwiftUI
import MapKit

struct MapPickerView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var address: String
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            MapReader { proxy in
                Map(initialPosition: .region(region)) {
                    // Если координаты выбраны, показываем аннотацию
                    if let coordinate = selectedLocation {
                        Annotation("", coordinate: coordinate) {
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
                .onMapCameraChange { context in
                    region = context.region
                }
                .onTapGesture { position in
                    // При тапе по карте получаем координаты
                    if let coordinate = proxy.convert(position, from: .local) {
                        selectedLocation = coordinate
                        
                        // После выбора точки делаем reverse geocoding:
                        reverseGeocode(coordinate) { placemark in
                            // Форматируем и записываем адрес в поле address
                            address = formatAddress(from: placemark)
                        }
                    }
                }
            }
            .navigationTitle("Pick Location")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // Обратное геокодирование (async замыкание для удобства)
    private func reverseGeocode(
        _ coordinate: CLLocationCoordinate2D,
        completion: @escaping (CLPlacemark?) -> Void
    ) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                // В реальном проекте можно отобразить errorMessage
                completion(nil)
                return
            }
            completion(placemarks?.first)
        }
    }
    
    // Формирование человекочитаемого адреса из placemark
    private func formatAddress(from placemark: CLPlacemark?) -> String {
        guard let placemark = placemark else { return "" }
        
        // Составляем строку из нужных компонентов
        let name = placemark.name ?? ""
        let locality = placemark.locality ?? ""
        let administrativeArea = placemark.administrativeArea ?? ""
        let country = placemark.country ?? ""
        
        // Фильтруем пустые части и объединяем запятой
        let addressComponents = [name, locality, administrativeArea, country]
            .filter { !$0.isEmpty }
        
        return addressComponents.joined(separator: ", ")
    }
}

#Preview {
    @Previewable @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Previewable @State var selectedLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    @Previewable @State var address: String = ""

    return MapPickerView(
        region: $region,
        selectedLocation: $selectedLocation,
        address: $address
    )
}

