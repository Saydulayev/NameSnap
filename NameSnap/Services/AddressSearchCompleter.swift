//
//  AddressSearchCompleter.swift
//  NameSnap
//
//  Created by Saydulayev on 18.01.25.
//

import Foundation
import Observation
import MapKit

@Observable
final class AddressSearchCompleter: NSObject, MKLocalSearchCompleterDelegate {
    var suggestions: [MKLocalSearchCompletion] = []
    
    private let completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        completer.delegate = self
        // По умолчанию completer.resultTypes = .address, можно менять
        // например на .address, .pointOfInterest, etc.
        completer.resultTypes = .address
    }
    
    func updateQuery(_ query: String) {
        completer.queryFragment = query
    }
    
    // MARK: - MKLocalSearchCompleterDelegate
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Completer error: \(error.localizedDescription)")
    }
}
