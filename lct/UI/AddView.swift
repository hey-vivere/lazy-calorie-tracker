//
//  AddView.swift
//  lct
//
//  Created by Nikola Klipa on 10/13/25.
//

import SwiftUI

struct AddView: View {
    @EnvironmentObject private var mealsStore: MealsStore

    @State private var showManualEntry = false
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("Add Meal")
            .sheet(isPresented: $showManualEntry) {
                ManualEntryView()
            }
            .fullScreenCover(isPresented: $showCamera) {
                QuickCaptureFlow(isPresented: $showCamera)
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Log a meal")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                // Camera Button
                Button {
                    showCamera = true
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 28))
                        Text("Camera")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)

                // Manual Button
                Button {
                    showManualEntry = true
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "pencil.line")
                            .font(.system(size: 28))
                        Text("Manual")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    AddView()
        .environmentObject(MealsStore())
}
