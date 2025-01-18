//
//  DetailView.swift
//  NameSnap
//
//  Created by Saydulayev on 15.01.25.
//

import SwiftUI
import MapKit
import CoreLocation


struct DetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isEditing = false
    @State private var scale: CGFloat = 1.0
    @State private var isTextHidden = false
    @State private var isSharing = false
    @State private var shareItems: [Any] = []
    @State private var selectedView: String = "Photo"

    @Bindable var photo: NamedPhoto

    var body: some View {
        VStack {
            Picker("View Mode", selection: $selectedView) {
                Text("Photo").tag("Photo")
                Text("Map").tag("Map")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if selectedView == "Photo" {
                if let uiImage = UIImage(data: photo.photo) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                        .scaleEffect(scale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = value
                                    withAnimation(.easeInOut) {
                                        isTextHidden = scale > 1.0
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.5)) {
                                        scale = 1.0
                                        isTextHidden = false
                                    }
                                }
                        )
                }

                if !isTextHidden {
                    Text(photo.name)
                        .font(.title)
                        .padding()
                        .animation(.easeInOut, value: isTextHidden)
                }
            } else if selectedView == "Map", let latitude = photo.latitude, let longitude = photo.longitude {
                PhotoLocationMapView(latitude: latitude, longitude: longitude)
                    .frame(height: 300)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .navigationTitle("Photo Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: sharePhoto) {
                    Image(systemName: "square.and.arrow.up")
                }
                .font(.headline)

                Button("Edit") {
                    isEditing = true
                }
                .font(.headline)
            }
        }
        .sheet(isPresented: $isEditing) {
            EditPhotoView(photo: Binding(get: { photo }, set: { updatedPhoto in
                photo.name = updatedPhoto.name
                photo.photo = updatedPhoto.photo
            }))
        }
        .sheet(isPresented: $isSharing) {
            ActivityViewController(activityItems: shareItems)
        }
    }

    func sharePhoto() {
        guard let uiImage = UIImage(data: photo.photo) else { return }
        shareItems = [photo.name, uiImage]
        isSharing = true
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    @Bindable var samplePhoto = NamedPhoto(
        name: "Sample Photo",
        photo: UIImage(systemName: "photo")!.jpegData(compressionQuality: 1.0)!
    )
    
    DetailView(photo: samplePhoto)
}



