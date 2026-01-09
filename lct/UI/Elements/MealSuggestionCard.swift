//
//  MealSuggestionCard.swift
//  lct
//
//  Created by Claude on 01/09/26.
//

import SwiftUI

struct MealSuggestionCard: View {
    let template: MealTemplate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                photoView
                    .frame(width: 100, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(template.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, alignment: .leading)

                Text("\(template.averageCalories) kcal")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 100)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var photoView: some View {
        switch template.displayImageSource {
        case .local(let path):
            if let image = UIImage(contentsOfFile: path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                mealPlaceholder
            }
        case .remote(let url):
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                mealPlaceholder
            }
        case .none:
            mealPlaceholder
        }
    }

    private var mealPlaceholder: some View {
        ZStack {
            Color(.systemGray5)
            Image(systemName: "fork.knife")
                .font(.title2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: 12) {
            ForEach(MealTemplate.mockData) { template in
                MealSuggestionCard(template: template) {}
            }
        }
        .padding()
    }
}
