//
//  NameSnapApp.swift
//  NameSnap
//
//  Created by Saydulayev on 14.01.25.
//

import SwiftUI

@main
struct NameSnapApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: NamedPhoto.self)
    }
}
