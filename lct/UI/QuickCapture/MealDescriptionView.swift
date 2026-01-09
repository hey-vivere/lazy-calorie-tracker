//
//  MealDescriptionView.swift
//  lct
//
//  Created by Claude on 1/9/26.
//

import SwiftUI
import CoreLocation

struct MealDescriptionView: View {
    let image: UIImage
    let location: CLLocation?
    @Binding var isPresented: Bool

    @EnvironmentObject private var mealsStore: MealsStore

    @State private var description: String = ""
    @State private var isSubmitting: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    private let suggestions = ["ate half", "extra large", "with sauce", "no dressing", "fried", "grilled"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                GeometryReader { geo in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                .frame(height: UIScreen.main.bounds.height * 0.45)

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add notes (optional)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        TextField("e.g., ate half, extra oily...", text: $description)
                            .textFieldStyle(.roundedBorder)
                            .focused($isTextFieldFocused)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestions, id: \.self) { suggestion in
                                Button {
                                    if description.isEmpty {
                                        description = suggestion
                                    } else {
                                        description += ", \(suggestion)"
                                    }
                                } label: {
                                    Text(suggestion)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray5))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Spacer()

                    Button {
                        submitMeal()
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "paperplane.fill")
                            }
                            Text(isSubmitting ? "Logging..." : "Log Meal")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isSubmitting ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isSubmitting)
                }
                .padding(20)
            }
            .navigationTitle("Add Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }

    private func submitMeal() {
        guard !isSubmitting else { return }
        isSubmitting = true

        Task {
            await mealsStore.submitQuickCapture(
                image: image,
                notes: description.isEmpty ? nil : description,
                location: location
            )
            withAnimation(.easeInOut(duration: 0.3)) {
                isPresented = false
            }
        }
    }
}

#Preview {
    MealDescriptionView(
        image: UIImage(systemName: "photo")!,
        location: nil,
        isPresented: .constant(true)
    )
    .environmentObject(MealsStore.mock)
}
