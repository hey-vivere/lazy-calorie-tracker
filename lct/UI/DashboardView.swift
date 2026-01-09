//
//  DashboardView.swift
//  lct
//
//  Created by Nikola Klipa on 10/13/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var mealsStore: MealsStore

    @State private var showQuickCapture = false
    @State private var dragOffset: CGFloat = 0

    private let swipeThreshold: CGFloat = 100

    var body: some View {
        ZStack {
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
            .offset(x: dragOffset)

            if dragOffset > 20 {
                HStack {
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                        Text("Quick Add")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .frame(width: min(dragOffset, 80))
                    .frame(maxHeight: .infinity)
                    .background(Color.blue.opacity(min(dragOffset / swipeThreshold, 1.0)))

                    Spacer()
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.width > 0 {
                        dragOffset = value.translation.width
                    }
                }
                .onEnded { value in
                    withAnimation(.spring(response: 0.3)) {
                        if value.translation.width > swipeThreshold {
                            showQuickCapture = true
                        }
                        dragOffset = 0
                    }
                }
        )
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showQuickCapture) {
            QuickCaptureFlow(isPresented: $showQuickCapture)
                .environmentObject(mealsStore)
        }
    }

    private var totalCalories: Int {
        mealsStore.meals
            .filter { $0.status == .completed }
            .compactMap { $0.calories }
            .reduce(0, +)
    }
}

#Preview {
    DashboardView()
        .environmentObject(MealsStore.mock)
}
