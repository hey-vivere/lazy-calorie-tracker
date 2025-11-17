//
//  MealRowView.swift
//  lct
//
//  Created by Nikola Klipa on 10/20/25.
//

import SwiftUI

struct MealRowView: View {
    let meal: DashboardMeal

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: meal.photoURL ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading) {
                Text(meal.templateName ?? "Unnamed Meal")
                    .font(.headline)
                Text("\(meal.calories) kcal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    MealRowView(meal: DashboardMeal.mockData[0])
}
