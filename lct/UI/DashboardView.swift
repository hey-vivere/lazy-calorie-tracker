//
//  DashboardView.swift
//  lct
//
//  Created by Nikola Klipa on 10/13/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var mealsStore: MealsStore
    @Binding var showQuickCapture: Bool

    private let swipeThreshold: CGFloat = 100

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Spacer(minLength: 20)
                CalorieProgressView(currentCalories: totalCalories, goalCalories: 2700)
                Spacer(minLength: 20)
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: 260)
            .background(Color(.systemGray6))

            MealsListView()
                .padding(.top, 4)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > swipeThreshold {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showQuickCapture = true
                        }
                    }
                }
        )
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
    }

    private var totalCalories: Int {
        mealsStore.meals
            .filter { $0.status == .completed }
            .compactMap { $0.calories }
            .reduce(0, +)
    }
}

#Preview {
    DashboardView(showQuickCapture: .constant(false))
        .environmentObject(MealsStore.mock)
}
