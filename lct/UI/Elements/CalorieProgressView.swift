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
        ZStack {
            // Background circle
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.2)
                .foregroundColor(.gray)
            
            // Progress circle
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(
                    Color.green,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            // Over-goal gradient ring
            if progress > 1 {
                Circle()
                    .trim(from: 0.0, to: min(progress - 1.0, 1.0))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(stops: [
                                .init(color: .orange, location: 0.0),
                                .init(color: .red, location: 0.3)
                            ]),
                            center: .center,
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.4), value: progress)
            }
            
            if progress > 2 {
                Circle()
                    .trim(from: 0.0, to: min(progress - 1.0, 1.0)) // up to +30%
                    .stroke(
                        Color.red,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.4), value: progress)
            }
            
            // Text overlay
            VStack(spacing: 4) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 32, weight: .bold))
                Text("\(currentCalories) / \(goalCalories) kcal")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 180, height: 180)
    }
}

#Preview {
    CalorieProgressView(currentCalories: 2500, goalCalories: 1800)
}
