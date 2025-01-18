//
//  Model.swift
//  NameSnap
//
//  Created by Saydulayev on 14.01.25.
//


import Foundation
import SwiftData

@Model
final class NamedPhoto: Identifiable, Comparable {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    @Attribute(.externalStorage) var photo: Data
    var dateAdded: Date
    
    var latitude: Double?
    var longitude: Double?
    var city: String? 

    init(name: String,
         photo: Data,
         dateAdded: Date = Date(),
         latitude: Double? = nil,
         longitude: Double? = nil,
         city: String? = nil) {
        self.name = name
        self.photo = photo
        self.dateAdded = dateAdded
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
    }

    static func < (lhs: NamedPhoto, rhs: NamedPhoto) -> Bool {
        lhs.name.localizedCompare(rhs.name) == .orderedAscending
    }
}




