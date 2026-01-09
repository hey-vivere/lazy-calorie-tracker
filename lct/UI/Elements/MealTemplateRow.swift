//
//  MealTemplateRow.swift
//  lct
//
//  Created by Claude on 01/09/26.
//

import SwiftUI

struct MealTemplateRow: View {
    let template: MealTemplate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                photoView
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(template.name)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text("\(template.averageCalories) kcal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
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
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        ForEach(MealTemplate.mockData) { template in
            MealTemplateRow(template: template) {}
        }
    }
    .padding()
}
