//
//  CalorieProgressView.swift
//  lct
//
//  Created by Nikola Klipa on 10/13/25.
//

import SwiftUI

struct CalorieProgressView: View {
    var currentCalories: Int
    var goalCalories: Int

    var body: some View {
        let progress = Double(currentCalories) / Double(goalCalories)

        VStack(spacing: 16) {
            // Breathing blob visualization
            BreathingBlobView(progress: progress)
                .frame(width: 160, height: 160)
                .drawingGroup()  // GPU-accelerated rendering

            // Calorie text below the blob
            VStack(spacing: 4) {
                Text("\(currentCalories)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: currentCalories)

                Text("of \(goalCalories) kcal")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 180, height: 220)
    }
}

#Preview("Under Goal") {
    CalorieProgressView(currentCalories: 1200, goalCalories: 2000)
}

#Preview("At Goal") {
    CalorieProgressView(currentCalories: 2000, goalCalories: 2000)
}

#Preview("Over Goal") {
    CalorieProgressView(currentCalories: 2500, goalCalories: 1800)
}
