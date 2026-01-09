//
//  AppModel.swift
//  lct
//
//  Created by Nikola Klipa on 11/17/25.
//
import Foundation
import Combine
import SwiftUI
import UIKit
import CoreLocation

final class MealsStore: ObservableObject {

    @Published var meals: [DashboardMeal] = []

    private let estimationService: MealEstimationServiceProtocol
    private let photoStorage: PhotoStorageServiceProtocol

    init(
        estimationService: MealEstimationServiceProtocol = MockMealEstimationService(),
        photoStorage: PhotoStorageServiceProtocol = LocalPhotoStorageService()
    ) {
        self.estimationService = estimationService
        self.photoStorage = photoStorage
    }

    func add(_ meal: DashboardMeal) {
        meals.insert(meal, at: 0)
    }

    func remove(at offsets: IndexSet) {
        for index in offsets {
            if let path = meals[index].localPhotoPath {
                try? photoStorage.delete(path: path)
            }
        }
        meals.remove(atOffsets: offsets)
    }

    @MainActor
    func submitQuickCapture(image: UIImage, notes: String?) async {
        let id = UUID().uuidString
        let capturedAt = Date()
        let mealTime = ISO8601DateFormatter().string(from: capturedAt)

        guard let localPath = try? photoStorage.save(image: image, withId: id) else {
            let failedMeal = DashboardMeal(
                id: id,
                templateId: nil,
                templateName: nil,
                calories: nil,
                mealTime: mealTime,
                photoURL: nil,
                localPhotoPath: nil,
                userNotes: notes,
                status: .failed,
                errorMessage: "Could not save photo"
            )
            add(failedMeal)
            return
        }

        let pendingMeal = DashboardMeal(
            id: id,
            templateId: nil,
            templateName: nil,
            calories: nil,
            mealTime: mealTime,
            photoURL: nil,
            localPhotoPath: localPath,
            userNotes: notes,
            status: .pending,
            errorMessage: nil
        )
        add(pendingMeal)

        // Fire off processing in background - don't await, return immediately
        Task {
            await processMeal(id: id, image: image, notes: notes, localPath: localPath, capturedAt: capturedAt)
        }
    }

    @MainActor
    private func processMeal(id: String, image: UIImage, notes: String?, localPath: String, capturedAt: Date) async {
        updateMealStatus(id: id, status: .processing)

        do {
            let result = try await estimationService.estimate(image: image, notes: notes)

            updateMealWithResult(
                id: id,
                name: result.mealName,
                calories: result.calories,
                status: .completed
            )
        } catch {
            updateMealWithError(id: id, error: error.localizedDescription)
        }
    }

    private func updateMealStatus(id: String, status: MealStatus) {
        guard let index = meals.firstIndex(where: { $0.id == id }) else { return }
        let old = meals[index]
        meals[index] = DashboardMeal(
            id: old.id,
            templateId: old.templateId,
            templateName: old.templateName,
            calories: old.calories,
            mealTime: old.mealTime,
            photoURL: old.photoURL,
            localPhotoPath: old.localPhotoPath,
            userNotes: old.userNotes,
            status: status,
            errorMessage: old.errorMessage,
            latitude: old.latitude,
            longitude: old.longitude,
            source: old.source
        )
    }

    private func updateMealWithResult(id: String, name: String, calories: Int, status: MealStatus) {
        guard let index = meals.firstIndex(where: { $0.id == id }) else { return }
        let old = meals[index]
        meals[index] = DashboardMeal(
            id: old.id,
            templateId: old.templateId,
            templateName: name,
            calories: calories,
            mealTime: old.mealTime,
            photoURL: old.photoURL,
            localPhotoPath: old.localPhotoPath,
            userNotes: old.userNotes,
            status: status,
            errorMessage: nil,
            latitude: old.latitude,
            longitude: old.longitude,
            source: old.source
        )
    }

    private func updateMealWithError(id: String, error: String) {
        guard let index = meals.firstIndex(where: { $0.id == id }) else { return }
        let old = meals[index]
        meals[index] = DashboardMeal(
            id: old.id,
            templateId: old.templateId,
            templateName: "Analysis failed",
            calories: nil,
            mealTime: old.mealTime,
            photoURL: old.photoURL,
            localPhotoPath: old.localPhotoPath,
            userNotes: old.userNotes,
            status: .failed,
            errorMessage: error,
            latitude: old.latitude,
            longitude: old.longitude,
            source: old.source
        )
    }

    @MainActor
    func retryEstimation(for mealId: String) async {
        guard let meal = meals.first(where: { $0.id == mealId }),
              let localPath = meal.localPhotoPath,
              let image = photoStorage.load(path: localPath) else { return }

        await processMeal(
            id: mealId,
            image: image,
            notes: meal.userNotes,
            localPath: localPath,
            capturedAt: ISO8601DateFormatter().date(from: meal.mealTime) ?? Date()
        )
    }

    // MARK: - Manual Entry

    @MainActor
    func addManualMeal(name: String, calories: Int, image: UIImage?, at location: CLLocation?) {
        let id = UUID().uuidString
        let mealTime = ISO8601DateFormatter().string(from: Date())

        var localPath: String? = nil
        if let image = image {
            localPath = try? photoStorage.save(image: image, withId: id)
        }

        let meal = DashboardMeal(
            id: id,
            templateId: UUID().uuidString,
            templateName: name,
            calories: calories,
            mealTime: mealTime,
            photoURL: nil,
            localPhotoPath: localPath,
            userNotes: nil,
            status: .completed,
            errorMessage: nil,
            latitude: location?.coordinate.latitude,
            longitude: location?.coordinate.longitude,
            source: .manual
        )
        add(meal)
    }
}

extension MealsStore {
    static var mock: MealsStore {
        let store = MealsStore()
        store.meals = DashboardMeal.mockData
        return store
    }
}

final class AppModel: ObservableObject {
    @MainActor
    let mealsStore = MealsStore()
}
