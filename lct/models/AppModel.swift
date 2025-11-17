//
//  AppModel.swift
//  lct
//
//  Created by Nikola Klipa on 11/17/25.
//
import Foundation
import Combine
import SwiftUI

final class MealsStore: ObservableObject {
    
    @Published var meals: [DashboardMeal] = []
    
    func add(_ meal: DashboardMeal) {
        meals.append(meal)
    }
    
    func remove(at offsets: IndexSet) {
        meals.remove(atOffsets: offsets)
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
