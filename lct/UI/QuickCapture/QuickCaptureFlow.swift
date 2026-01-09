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
                    onClose: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    },
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
        .photosPicker(
            isPresented: $showGalleryPicker,
            selection: $selectedItem,
            matching: .images
        )
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

#Preview {
    QuickCaptureFlow(isPresented: .constant(true))
        .environmentObject(MealsStore.mock)
}
