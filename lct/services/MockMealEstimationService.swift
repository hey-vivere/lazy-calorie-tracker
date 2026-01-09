//
//  MockMealEstimationService.swift
//  lct
//
//  Created by Claude on 1/9/26.
//

import Foundation
import UIKit

final class MockMealEstimationService: MealEstimationServiceProtocol {

    private let mockMeals: [(name: String, calories: Int)] = [
        ("Grilled Chicken Salad", 350),
        ("Pasta Carbonara", 650),
        ("Avocado Toast", 280),
        ("Burger with Fries", 850),
        ("Greek Yogurt Bowl", 220),
        ("Salmon with Vegetables", 480),
        ("Pizza Slice", 290),
        ("Oatmeal with Berries", 310),
        ("Steak Dinner", 720),
        ("Caesar Salad", 380),
        ("Sushi Roll", 320),
        ("Pad Thai", 620),
        ("Chicken Tikka Masala", 550),
        ("Veggie Wrap", 380),
        ("Acai Bowl", 450)
    ]

    var simulatedDelay: TimeInterval = 2.0
    var failureRate: Double = 0.1

    func estimate(image: UIImage, notes: String?) async throws -> MealEstimationResult {
        try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))

        if Double.random(in: 0...1) < failureRate {
            throw MealEstimationError.serverError(message: "Service temporarily unavailable")
        }

        let randomMeal = mockMeals.randomElement()!

        var adjustedCalories = randomMeal.calories
        if let notes = notes?.lowercased() {
            if notes.contains("half") || notes.contains("small") {
                adjustedCalories = Int(Double(adjustedCalories) * 0.5)
            } else if notes.contains("large") || notes.contains("extra") {
                adjustedCalories = Int(Double(adjustedCalories) * 1.3)
            }
            if notes.contains("oily") || notes.contains("fried") {
                adjustedCalories = Int(Double(adjustedCalories) * 1.2)
            }
        }

        return MealEstimationResult(
            mealName: randomMeal.name,
            calories: adjustedCalories,
            confidence: Double.random(in: 0.7...0.95)
        )
    }
}
