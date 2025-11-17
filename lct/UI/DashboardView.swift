//
//  DashboardView.swift
//  lct
//
//  Created by Nikola Klipa on 10/13/25.
//
//
//  DashboardView.swift
//  lct
//
//  Created by Nikola Klipa on 10/13/25.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack(spacing: 0) {
            // 🟢 Fixed top section
            VStack {
                Spacer(minLength: 20)
                CalorieProgressView(currentCalories: 1700, goalCalories: 2700)
                Spacer(minLength: 20)
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: 260)
            .background(Color(.systemGray6))


            MealsListView()
                .padding(.top, 4)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
    }
}
#Preview {
    DashboardView()
        .environmentObject(MealsStore.mock)
}
