//
//  MealRowView.swift
//  lct
//
//  Created by Nikola Klipa on 10/20/25.
//

import SwiftUI

struct MealRowView: View {
    let meal: DashboardMeal
    var onRetry: (() -> Void)?

    var body: some View {
        HStack {
            ZStack {
                mealImage
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                if meal.isPending {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 60, height: 60)

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }

                if meal.status == .failed {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.red.opacity(0.3))
                        .frame(width: 60, height: 60)

                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(meal.displayName)
                        .font(.headline)
                        .foregroundColor(meal.status == .failed ? .red : .primary)

                    if meal.isPending {
                        Text("analyzing...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }

                HStack {
                    if meal.isPending {
                        HStack(spacing: 2) {
                            ForEach(0..<3, id: \.self) { _ in
                                Circle()
                                    .fill(Color.secondary)
                                    .frame(width: 4, height: 4)
                                    .opacity(0.5)
                            }
                            Text("kcal")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    } else if meal.status == .failed {
                        Button {
                            onRetry?()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise")
                                Text("Retry")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    } else {
                        Text(meal.displayCalories)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                if let notes = meal.userNotes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .opacity(meal.isPending ? 0.8 : 1.0)
    }

    @ViewBuilder
    private var mealImage: some View {
        switch meal.displayImageSource {
        case .local(let path):
            if let uiImage = UIImage(contentsOfFile: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                imagePlaceholder
            }
        case .remote(let url):
            AsyncImage(url: URL(string: url)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                imagePlaceholder
            }
        case .none:
            imagePlaceholder
        }
    }

    private var imagePlaceholder: some View {
        Color.gray.opacity(0.2)
    }
}

#Preview {
    MealRowView(meal: DashboardMeal.mockData[0])
}
