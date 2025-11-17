//
//  AddView.swift
//  lct
//
//  Created by Nikola Klipa on 10/13/25.
//

import SwiftUI

struct AddView: View {
    @EnvironmentObject private var mealsStore: MealsStore
    
    var body: some View {
        Button("Save") {
            mealsStore.add(DashboardMeal(
                id: UUID().uuidString,
                templateId: UUID().uuidString,
                templateName: "Ho ho",
                calories: 480,
                mealTime: "2025-10-20T09:30:00Z",
                photoURL: "https://picsum.photos/200/201"
            ))
        }
    }
}

#Preview {
    AddView()
}
