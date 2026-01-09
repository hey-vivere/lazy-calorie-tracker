//
//  PhotoLocationExtractor.swift
//  lct
//
//  Created by Claude on 01/09/26.
//

import Foundation
import Photos
import CoreLocation
import ImageIO
import UIKit

struct PhotoLocationExtractor {
    /// Extract location from UIImagePickerController info dictionary (camera capture)
    static func extractFromPickerInfo(_ info: [UIImagePickerController.InfoKey: Any]) -> CLLocation? {
        guard let metadata = info[.mediaMetadata] as? [String: Any],
              let gps = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any],
              let lat = gps[kCGImagePropertyGPSLatitude as String] as? Double,
              let lon = gps[kCGImagePropertyGPSLongitude as String] as? Double else {
            return nil
        }

        let latRef = gps[kCGImagePropertyGPSLatitudeRef as String] as? String ?? "N"
        let lonRef = gps[kCGImagePropertyGPSLongitudeRef as String] as? String ?? "E"

        let finalLat = latRef == "S" ? -lat : lat
        let finalLon = lonRef == "W" ? -lon : lon

        return CLLocation(latitude: finalLat, longitude: finalLon)
    }

    /// Extract location from PHAsset (photo library selection)
    static func extractFromAsset(_ asset: PHAsset) -> CLLocation? {
        return asset.location
    }

    /// Extract location from image data (e.g., from PhotosPicker)
    static func extractFromImageData(_ data: Data) -> CLLocation? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
              let gps = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any],
              let lat = gps[kCGImagePropertyGPSLatitude as String] as? Double,
              let lon = gps[kCGImagePropertyGPSLongitude as String] as? Double else {
            return nil
        }

        let latRef = gps[kCGImagePropertyGPSLatitudeRef as String] as? String ?? "N"
        let lonRef = gps[kCGImagePropertyGPSLongitudeRef as String] as? String ?? "E"

        let finalLat = latRef == "S" ? -lat : lat
        let finalLon = lonRef == "W" ? -lon : lon

        return CLLocation(latitude: finalLat, longitude: finalLon)
    }
}
