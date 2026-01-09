//
//  MealSuggestionService.swift
//  lct
//
//  Created by Claude on 01/09/26.
//

import Foundation
import CoreLocation

protocol MealSuggestionServiceProtocol {
    func fetchSuggestionsNearLocation(lat: Double, lon: Double, radiusMeters: Double) async throws -> [MealTemplate]
    func fetchMostCommon(limit: Int) async throws -> [MealTemplate]
    func searchMeals(query: String) async throws -> [MealTemplate]
}

final class MockMealSuggestionService: MealSuggestionServiceProtocol {
    private let mealsProvider: () -> [DashboardMeal]

    init(mealsProvider: @escaping () -> [DashboardMeal]) {
        self.mealsProvider = mealsProvider
    }

    func fetchSuggestionsNearLocation(lat: Double, lon: Double, radiusMeters: Double) async throws -> [MealTemplate] {
        let targetLocation = CLLocation(latitude: lat, longitude: lon)
        let meals = mealsProvider()

        let nearbyMeals = meals.filter { meal in
            guard let mealLat = meal.latitude, let mealLon = meal.longitude else {
                return false
            }
            let mealLocation = CLLocation(latitude: mealLat, longitude: mealLon)
            return mealLocation.distance(from: targetLocation) <= radiusMeters
        }

        return deduplicateToTemplates(meals: nearbyMeals)
    }

    func fetchMostCommon(limit: Int) async throws -> [MealTemplate] {
        let meals = mealsProvider()
        let templates = deduplicateToTemplates(meals: meals)
        return Array(templates.prefix(limit))
    }

    func searchMeals(query: String) async throws -> [MealTemplate] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }

        let meals = mealsProvider()
        let matchingMeals = meals.filter { meal in
            guard let name = meal.templateName else { return false }
            return name.localizedCaseInsensitiveContains(query)
        }

        return deduplicateToTemplates(meals: matchingMeals)
    }

    private func deduplicateToTemplates(meals: [DashboardMeal]) -> [MealTemplate] {
        let completedMeals = meals.filter { $0.status == .completed && $0.templateId != nil }

        let grouped = Dictionary(grouping: completedMeals) { $0.templateId! }

        return grouped.compactMap { templateId, meals -> MealTemplate? in
            guard let firstName = meals.first?.templateName else { return nil }

            let calories = meals.compactMap { $0.calories }
            let avgCalories = calories.isEmpty ? 0 : calories.reduce(0, +) / calories.count

            let sortedByTime = meals.sorted { $0.mealTime > $1.mealTime }
            let recentWithPhoto = sortedByTime.first { $0.localPhotoPath != nil || $0.photoURL != nil }

            return MealTemplate(
                id: templateId,
                name: firstName,
                averageCalories: avgCalories,
                logCount: meals.count,
                lastPhotoPath: recentWithPhoto?.localPhotoPath,
                photoURL: recentWithPhoto?.photoURL
            )
        }
        .sorted { $0.logCount > $1.logCount }
    }
}
