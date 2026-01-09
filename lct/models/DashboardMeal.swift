//
//  DashboardMeal.swift
//  lct
//
//  Created by Nikola Klipa on 10/20/25.
//

import Foundation

enum MealStatus: String, Codable {
    case pending
    case processing
    case completed
    case failed
}

enum ImageSource: Hashable {
    case local(String)
    case remote(String)
    case none
}

struct DashboardMeal: Identifiable, Codable, Hashable {
    let id: String
    let templateId: String?
    let templateName: String?
    let calories: Int?
    let mealTime: String
    let photoURL: String?
    let localPhotoPath: String?
    let userNotes: String?
    let status: MealStatus
    let errorMessage: String?

    var displayImageSource: ImageSource {
        if let localPath = localPhotoPath {
            return .local(localPath)
        } else if let url = photoURL {
            return .remote(url)
        }
        return .none
    }

    var displayName: String {
        templateName ?? "Analyzing meal..."
    }

    var displayCalories: String {
        guard let cal = calories else { return "..." }
        return "\(cal) kcal"
    }

    var isPending: Bool {
        status == .pending || status == .processing
    }

    // Convenience initializer for backwards compatibility
    init(
        id: String,
        templateId: String?,
        templateName: String?,
        calories: Int?,
        mealTime: String,
        photoURL: String?,
        localPhotoPath: String? = nil,
        userNotes: String? = nil,
        status: MealStatus = .completed,
        errorMessage: String? = nil
    ) {
        self.id = id
        self.templateId = templateId
        self.templateName = templateName
        self.calories = calories
        self.mealTime = mealTime
        self.photoURL = photoURL
        self.localPhotoPath = localPhotoPath
        self.userNotes = userNotes
        self.status = status
        self.errorMessage = errorMessage
    }
}

extension DashboardMeal {
    static let mockData: [DashboardMeal] = [
        DashboardMeal(
            id: UUID().uuidString,
            templateId: UUID().uuidString,
            templateName: "Pad Thai with Chicken",
            calories: 620,
            mealTime: "2025-10-20T12:00:00Z",
            photoURL: "https://picsum.photos/200/200"
        ),
        DashboardMeal(
            id: UUID().uuidString,
            templateId: UUID().uuidString,
            templateName: "Eggs Benedict",
            calories: 480,
            mealTime: "2025-10-20T09:30:00Z",
            photoURL: "https://picsum.photos/200/201"
        ),
        DashboardMeal(
            id: UUID().uuidString,
            templateId: UUID().uuidString,
            templateName: "Grilled Salmon Bowl",
            calories: 540,
            mealTime: "2025-10-20T19:00:00Z",
            photoURL: "https://picsum.photos/200/202"
        )
    ]
}
