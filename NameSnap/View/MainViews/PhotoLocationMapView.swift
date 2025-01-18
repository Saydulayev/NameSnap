//
//  PhotoLocationMapView.swift
//  NameSnap
//
//  Created by Saydulayev on 18.01.25.
//

import SwiftUI
import CoreLocation
import MapKit

struct PhotoLocationMapView: View {
    let latitude: Double
    let longitude: Double

    @State private var region: MKCoordinateRegion
    @State private var address: String = "Loading address..."

    private let geocoder = CLGeocoder()

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude

        let initialLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        _region = State(initialValue: MKCoordinateRegion(
            center: initialLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        ZStack {
            Map(initialPosition: .region(region), interactionModes: .all) {
                Annotation("", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.red)
                    }
                }
            }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()

            VStack {
                Spacer()
                Text(address)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            }
        }
        .onAppear(perform: fetchAddress)
    }

    private func fetchAddress() {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                self.address = "Unable to fetch address"
                return
            }

            if let placemark = placemarks?.first {
                self.address = [
                    placemark.name,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ]
                .compactMap { $0 }
                .joined(separator: ", ")
            } else {
                self.address = "Address not found"
            }
        }
    }
}


#Preview {
    PhotoLocationMapView(latitude: 37.7749, longitude: -122.4194) 
}

