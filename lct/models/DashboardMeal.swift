//
//  DashboardMeal.swift
//  lct
//
//  Created by Nikola Klipa on 10/20/25.
//

import Foundation

struct DashboardMeal: Identifiable, Codable, Hashable {
    let id: String
    let templateId: String?
    let templateName: String?
    let calories: Int
    let mealTime: String
    let photoURL: String?
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
