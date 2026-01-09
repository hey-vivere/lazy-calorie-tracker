//
//  PhotoCaptureView.swift
//  lct
//
//  Created by Claude on 1/9/26.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct PhotoCaptureView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)

    var onImageCaptured: (UIImage) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                if cameraAvailable {
                    Button {
                        showCamera = true
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 48))
                            Text("Take Photo")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }

                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 48))
                        Text("Choose from Library")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Spacer()
            }
            .padding(24)
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            dismiss()
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView(
                    onClose: {
                        showCamera = false
                    },
                    onImageCaptured: { image, _ in
                        onImageCaptured(image)
                    },
                    onOpenGallery: {
                        // Gallery is already available on this screen, do nothing
                    }
                )
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        onImageCaptured(image)
                    }
                }
            }
        }
    }
}

#Preview {
    PhotoCaptureView { _ in }
}
