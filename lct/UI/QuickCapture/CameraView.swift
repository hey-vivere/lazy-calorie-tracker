//
//  CameraView.swift
//  lct
//
//  Created by Claude on 1/9/26.
//

import SwiftUI
import UIKit
import Photos

struct CameraView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    var onImageCaptured: (UIImage) -> Void
    var onOpenGallery: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.showsCameraControls = false

        // Create custom overlay
        let screenBounds = UIScreen.main.bounds
        let overlayView = CameraOverlayView(frame: screenBounds)

        // Capture callbacks
        let dismissAction = dismiss
        let galleryAction = onOpenGallery

        overlayView.onCapture = { [weak picker] in
            picker?.takePicture()
        }
        overlayView.onClose = {
            dismissAction()
        }
        overlayView.onGallery = {
            galleryAction()
        }

        // Fetch recent photo for thumbnail
        overlayView.loadRecentPhoto()

        picker.cameraOverlayView = overlayView

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Custom Camera Overlay

class CameraOverlayView: UIView {
    var onCapture: (() -> Void)?
    var onClose: (() -> Void)?
    var onGallery: (() -> Void)?

    private let captureButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    private let galleryButton = UIButton(type: .system)
    private let galleryImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        isUserInteractionEnabled = true

        // Capture button - white circle with inner circle
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.backgroundColor = .white
        captureButton.layer.cornerRadius = 35
        captureButton.layer.borderWidth = 4
        captureButton.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        captureButton.addTarget(self, action: #selector(captureTapped), for: .touchUpInside)
        addSubview(captureButton)

        // Close button - X icon
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        let closeConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: closeConfig), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addSubview(closeButton)

        // Gallery thumbnail button
        galleryButton.translatesAutoresizingMaskIntoConstraints = false
        galleryButton.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        galleryButton.layer.cornerRadius = 8
        galleryButton.layer.borderWidth = 2
        galleryButton.layer.borderColor = UIColor.white.cgColor
        galleryButton.clipsToBounds = true
        galleryButton.addTarget(self, action: #selector(galleryTapped), for: .touchUpInside)
        addSubview(galleryButton)

        // Gallery image view inside button
        galleryImageView.translatesAutoresizingMaskIntoConstraints = false
        galleryImageView.contentMode = .scaleAspectFill
        galleryImageView.clipsToBounds = true
        galleryImageView.isUserInteractionEnabled = false
        galleryButton.addSubview(galleryImageView)

        NSLayoutConstraint.activate([
            // Capture button - center bottom
            captureButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70),

            // Close button - top left
            closeButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),

            // Gallery button - bottom left
            galleryButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            galleryButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            galleryButton.widthAnchor.constraint(equalToConstant: 50),
            galleryButton.heightAnchor.constraint(equalToConstant: 50),

            // Gallery image fills button
            galleryImageView.topAnchor.constraint(equalTo: galleryButton.topAnchor),
            galleryImageView.bottomAnchor.constraint(equalTo: galleryButton.bottomAnchor),
            galleryImageView.leadingAnchor.constraint(equalTo: galleryButton.leadingAnchor),
            galleryImageView.trailingAnchor.constraint(equalTo: galleryButton.trailingAnchor),
        ])
    }

    @objc private func captureTapped() {
        onCapture?()
    }

    @objc private func closeTapped() {
        onClose?()
    }

    @objc private func galleryTapped() {
        onGallery?()
    }

    func loadRecentPhoto() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1

        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        guard let asset = fetchResult.firstObject else { return }

        let imageManager = PHImageManager.default()
        let targetSize = CGSize(width: 100, height: 100)
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true

        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { [weak self] image, _ in
            DispatchQueue.main.async {
                self?.galleryImageView.image = image
            }
        }
    }
}
