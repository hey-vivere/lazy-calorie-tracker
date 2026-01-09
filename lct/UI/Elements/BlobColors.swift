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

    /// Linear interpolation between two colors
    private static func interpolate(from: Color, to: Color, t: Double) -> Color {
        let t = max(0, min(1, t))  // Clamp to 0-1

        // Resolve colors in sRGB
        let fromResolved = UIColor(from).cgColor.components ?? [0, 0, 0, 1]
        let toResolved = UIColor(to).cgColor.components ?? [0, 0, 0, 1]

        // Handle grayscale colors (2 components) vs RGB (4 components)
        let fromR = fromResolved.count >= 3 ? fromResolved[0] : fromResolved[0]
        let fromG = fromResolved.count >= 3 ? fromResolved[1] : fromResolved[0]
        let fromB = fromResolved.count >= 3 ? fromResolved[2] : fromResolved[0]
        let fromA = fromResolved.count >= 4 ? fromResolved[3] : (fromResolved.count >= 2 ? fromResolved[1] : 1)

        let toR = toResolved.count >= 3 ? toResolved[0] : toResolved[0]
        let toG = toResolved.count >= 3 ? toResolved[1] : toResolved[0]
        let toB = toResolved.count >= 3 ? toResolved[2] : toResolved[0]
        let toA = toResolved.count >= 4 ? toResolved[3] : (toResolved.count >= 2 ? toResolved[1] : 1)

        return Color(
            red: fromR + (toR - fromR) * t,
            green: fromG + (toG - fromG) * t,
            blue: fromB + (toB - fromB) * t,
            opacity: fromA + (toA - fromA) * t
        )
    }
}
