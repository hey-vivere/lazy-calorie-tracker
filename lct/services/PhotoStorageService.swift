//
//  PhotoStorageService.swift
//  lct
//
//  Created by Claude on 1/9/26.
//

import Foundation
import UIKit

enum PhotoStorageError: Error {
    case compressionFailed
    case writeFailed
}

protocol PhotoStorageServiceProtocol {
    func save(image: UIImage, withId id: String) throws -> String
    func load(path: String) -> UIImage?
    func delete(path: String) throws
}

final class LocalPhotoStorageService: PhotoStorageServiceProtocol {

    private let fileManager = FileManager.default

    private var mealsPhotoDirectory: URL {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let mealsDirectory = documentsDirectory.appendingPathComponent("meal_photos", isDirectory: true)

        if !fileManager.fileExists(atPath: mealsDirectory.path) {
            try? fileManager.createDirectory(at: mealsDirectory, withIntermediateDirectories: true)
        }

        return mealsDirectory
    }

    func save(image: UIImage, withId id: String) throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw PhotoStorageError.compressionFailed
        }

        let fileName = "\(id).jpg"
        let filePath = mealsPhotoDirectory.appendingPathComponent(fileName)

        try data.write(to: filePath)

        return filePath.path
    }

    func load(path: String) -> UIImage? {
        return UIImage(contentsOfFile: path)
    }

    func delete(path: String) throws {
        try fileManager.removeItem(atPath: path)
    }
}
