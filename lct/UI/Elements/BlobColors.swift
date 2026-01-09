//
//  BlobColors.swift
//  lct
//
//  Created by Claude on 01/09/26.
//

import SwiftUI

/// Color palette and interpolation for the breathing blob calorie indicator.
/// All colors are intentionally pleasant - no alarming reds.
enum BlobColors {
    // MARK: - Cool Colors (0-100% progress)

    static let cool = Color(red: 0.4, green: 0.8, blue: 0.8)           // Soft teal
    static let coolAccent = Color(red: 0.5, green: 0.85, blue: 0.9)    // Light cyan
    static let coolDeep = Color(red: 0.3, green: 0.7, blue: 0.75)      // Deeper teal

    // MARK: - Warm Colors (100%+ progress transition)

    static let warmPeach = Color(red: 1.0, green: 0.85, blue: 0.75)    // Soft peach
    static let warmCoral = Color(red: 1.0, green: 0.7, blue: 0.6)      // Gentle coral
    static let warmAmber = Color(red: 1.0, green: 0.8, blue: 0.5)      // Warm amber (max)

    // MARK: - Color Interpolation

    /// Returns the primary blob color based on calorie progress.
    /// - Parameter progress: Ratio of current/goal calories (1.0 = 100%)
    /// - Returns: Interpolated color - cool teal at/under goal, warm shift when over
    static func primary(for progress: Double) -> Color {
        if progress <= 1.0 {
            return cool
        }

        // Over 100%: transition through warm colors
        // Caps at 30% over (1.3 progress) to prevent extreme colors
        let overage = min(progress - 1.0, 0.3) / 0.3  // Normalize to 0-1

        if overage < 0.5 {
            // First half: teal -> peach
            return interpolate(from: cool, to: warmPeach, t: overage * 2)
        } else {
            // Second half: peach -> coral (stop before amber for subtlety)
            return interpolate(from: warmPeach, to: warmCoral, t: (overage - 0.5) * 2)
        }
    }

    /// Returns the accent color (lighter, for mesh gradient edges)
    static func accent(for progress: Double) -> Color {
        if progress <= 1.0 {
            return coolAccent
        }

        let overage = min(progress - 1.0, 0.3) / 0.3
        return interpolate(from: coolAccent, to: warmPeach.opacity(0.8), t: overage)
    }

    /// Returns the deep color (darker, for mesh gradient center)
    static func deep(for progress: Double) -> Color {
        if progress <= 1.0 {
            return coolDeep
        }

        let overage = min(progress - 1.0, 0.3) / 0.3
        return interpolate(from: coolDeep, to: warmAmber, t: overage)
    }

    // MARK: - Helpers

    /// Linear interpolation between two colors using SwiftUI's native Color.resolve API
    private static func interpolate(from: Color, to: Color, t: Double) -> Color {
        let t = Float(max(0, min(1, t)))  // Clamp to 0-1

        // Use SwiftUI's native color resolution (iOS 17+)
        let fromResolved = from.resolve(in: EnvironmentValues())
        let toResolved = to.resolve(in: EnvironmentValues())

        return Color(
            red: Double(fromResolved.red + (toResolved.red - fromResolved.red) * t),
            green: Double(fromResolved.green + (toResolved.green - fromResolved.green) * t),
            blue: Double(fromResolved.blue + (toResolved.blue - fromResolved.blue) * t),
            opacity: Double(fromResolved.opacity + (toResolved.opacity - fromResolved.opacity) * t)
        )
    }
}
