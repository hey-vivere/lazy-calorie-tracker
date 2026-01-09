//
//  MealEstimationService.swift
//  lct
//
//  Created by Claude on 1/9/26.
//

import Foundation
import UIKit

struct MealEstimationResult {
    let mealName: String
    let calories: Int
    let confidence: Double
}

enum MealEstimationError: Error, LocalizedError {
    case imageProcessingFailed
    case networkError(underlying: Error)
    case serverError(message: String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Could not process the image"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

protocol MealEstimationServiceProtocol {
    func estimate(image: UIImage, notes: String?) async throws -> MealEstimationResult
}
