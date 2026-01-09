//
//  QuickCaptureFlow.swift
//  lct
//
//  Created by Claude on 1/9/26.
//

import SwiftUI
import PhotosUI

struct QuickCaptureFlow: View {
    @Binding var isPresented: Bool

    @State private var capturedImage: UIImage?
    @State private var showGalleryPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)

    var body: some View {
        Group {
            if let image = capturedImage {
                MealDescriptionView(image: image, isPresented: $isPresented)
            } else if cameraAvailable {
                CameraView(
                    onImageCaptured: { image in
                        capturedImage = image
                    },
                    onOpenGallery: {
                        showGalleryPicker = true
                    }
                )
                .ignoresSafeArea()
            } else {
                // Fallback for simulator - show photo picker directly
                PhotoCaptureView { image in
                    capturedImage = image
                }
            }
        }
        .sheet(isPresented: $showGalleryPicker) {
            GalleryPickerView(selectedItem: $selectedItem)
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    capturedImage = image
                    showGalleryPicker = false
                }
            }
        }
    }
}

// Simple wrapper for PhotosPicker that presents as a sheet
struct GalleryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                VStack(spacing: 20) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    Text("Tap to select a photo")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Photo Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    QuickCaptureFlow(isPresented: .constant(true))
        .environmentObject(MealsStore.mock)
}
