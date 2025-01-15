//
//  PhotoPickerView.swift
//  NameSnap
//
//  Created by Saydulayev on 14.01.25.
//


import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var imageData: Data?
    @Binding var errorMessage: String?
    
    let loadImage: () -> Void

    var body: some View {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                if imageData != nil {
                    VStack {
                        Text("Нажмите, чтобы выбрать другое изображение")
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    Image(systemName: "photo")
                        .foregroundStyle(.blue)
                }
            }
        .buttonStyle(.plain)
        .onChange(of: selectedItem, loadImage)
    }
}




//#Preview {
//    @State private var selectedItem: PhotosPickerItem?
//    @State private var imageData: Data?
//    @State private var errorMessage: String?
//
//    return PhotoPickerView(
//        selectedItem: $selectedItem,
//        imageData: $imageData,
//        errorMessage: $errorMessage
//    )
//}

