//
//  MealTemplate.swift
//  lct
//
//  Created by Claude on 01/09/26.
//

import Foundation

struct MealTemplate: Identifiable, Hashable {
    let id: String
    let name: String
    let averageCalories: Int
    let logCount: Int
    let lastPhotoPath: String?
    let photoURL: String?

    var displayImageSource: ImageSource {
        if let path = lastPhotoPath {
            return .local(path)
        } else if let url = photoURL {
            return .remote(url)
        }
        return .none
    }
}

extension MealTemplate {
    static let mockData: [MealTemplate] = [
        MealTemplate(
            id: "template-1",
            name: "Pad Thai with Chicken",
            averageCalories: 620,
            logCount: 5,
            lastPhotoPath: nil,
            photoURL: "https://picsum.photos/200/200"
        ),
        MealTemplate(
            id: "template-2",
            name: "Eggs Benedict",
            averageCalories: 480,
            logCount: 3,
            lastPhotoPath: nil,
            photoURL: "https://picsum.photos/200/201"
        ),
        MealTemplate(
            id: "template-3",
            name: "Grilled Salmon Bowl",
            averageCalories: 540,
            logCount: 2,
            lastPhotoPath: nil,
            photoURL: "https://picsum.photos/200/202"
        )
    ]
}
