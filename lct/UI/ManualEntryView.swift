//
//  ManualEntryView.swift
//  lct
//
//  Created by Claude on 01/09/26.
//

import SwiftUI

struct ManualEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var mealsStore: MealsStore
    @StateObject private var locationService = LocationService()

    @State private var mealName = ""
    @State private var caloriesText = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false

    @FocusState private var focusedField: Field?

    enum Field {
        case name, calories
    }

    private var isValid: Bool {
        !mealName.trimmingCharacters(in: .whitespaces).isEmpty &&
        Int(caloriesText) != nil &&
        (Int(caloriesText) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                photoSection
                mealInfoSection
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Log") {
                        saveMeal()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .fullScreenCover(isPresented: $showCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
            }
            .onAppear {
                focusedField = .name
                locationService.requestWhenInUseAuthorization()
                locationService.startUpdatingLocation()
            }
            .onDisappear {
                locationService.stopUpdatingLocation()
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var photoSection: some View {
        Section {
            VStack(spacing: 12) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                            .frame(height: 150)

                        VStack(spacing: 8) {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("Add photo (optional)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                HStack(spacing: 16) {
                    Button {
                        showCamera = true
                    } label: {
                        Label("Camera", systemImage: "camera")
                    }

                    Button {
                        showImagePicker = true
                    } label: {
                        Label("Gallery", systemImage: "photo.on.rectangle")
                    }

                    if selectedImage != nil {
                        Button(role: .destructive) {
                            selectedImage = nil
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        }
    }

    @ViewBuilder
    private var mealInfoSection: some View {
        Section {
            TextField("Meal name", text: $mealName)
                .focused($focusedField, equals: .name)

            HStack {
                TextField("Calories", text: $caloriesText)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .calories)
                Text("kcal")
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Actions

    private func saveMeal() {
        guard let calories = Int(caloriesText) else { return }

        mealsStore.addManualMeal(
            name: mealName.trimmingCharacters(in: .whitespaces),
            calories: calories,
            image: selectedImage,
            at: locationService.currentLocation
        )

        dismiss()
    }
}

#Preview {
    ManualEntryView()
        .environmentObject(MealsStore())
}
