//
//  Model.swift
//  NameSnap
//
//  Created by Saydulayev on 14.01.25.
//

import Foundation
import SwiftData
import CoreLocation

class LocationFetcher: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var lastKnownLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
    }

    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
    }
}


import Foundation
import SwiftData

@Model
final class NamedPhoto {
    @Attribute(.unique) var id: UUID
    var name: String
    @Attribute(.externalStorage) var photo: Data
    var dateAdded: Date
    
    var latitude: Double?
    var longitude: Double?

    init(name: String,
         photo: Data,
         dateAdded: Date = Date(),
         latitude: Double? = nil,
         longitude: Double? = nil)
    {
        self.id = UUID()
        self.name = name
        self.photo = photo
        self.dateAdded = dateAdded
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension NamedPhoto: Comparable {
    static func < (lhs: NamedPhoto, rhs: NamedPhoto) -> Bool {
        lhs.name.localizedCompare(rhs.name) == .orderedAscending
    }
}

