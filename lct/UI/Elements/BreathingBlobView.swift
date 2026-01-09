//
//  BreathingBlobView.swift
//  lct
//
//  Created by Claude on 01/09/26.
//

import SwiftUI

/// An organic, breathing blob that visualizes calorie progress with a fill level.
/// The fill rises from bottom to top as calories are consumed.
struct BreathingBlobView: View {
    let progress: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1/60, paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate

            BlobCanvas(progress: progress, time: time, reduceMotion: reduceMotion)
        }
        .accessibilityElement()
        .accessibilityLabel("Calorie progress")
        .accessibilityValue("\(Int(progress * 100)) percent of daily goal")
    }
}

/// Canvas view that draws the animated blob with fill level
private struct BlobCanvas: View {
    let progress: Double
    let time: TimeInterval
    let reduceMotion: Bool

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let baseRadius = min(size.width, size.height) / 2 * 0.85

            // Create the blob path
            let blobPath = createBlobPath(
                center: center,
                baseRadius: baseRadius,
                time: 0  // Static shape
            )

            // Apply breathing scale
            let scale = breatheScale(time: time)
            var transform = CGAffineTransform(translationX: -center.x, y: -center.y)
                .concatenating(CGAffineTransform(scaleX: scale, y: scale))
                .concatenating(CGAffineTransform(translationX: center.x, y: center.y))
            let scaledPath = blobPath.cgPath.copy(using: &transform)
            let blobSwiftPath = Path(scaledPath ?? blobPath.cgPath)

            // 1. Draw the blob shell (faint outline/container)
            let shellColor = BlobColors.cool.opacity(0.15)
            context.fill(blobSwiftPath, with: .color(shellColor))

            // Draw a subtle stroke for definition
            context.stroke(
                blobSwiftPath,
                with: .color(BlobColors.cool.opacity(0.3)),
                lineWidth: 1.5
            )

            // 2. Calculate fill level (capped at 100% for fill height)
            let fillProgress = min(progress, 1.0)

            // 3. Draw filled portion using clip
            if fillProgress > 0 {
                let blobBounds = blobSwiftPath.boundingRect
                let fillY = blobBounds.minY + blobBounds.height * (1 - fillProgress)

                // Create fill rectangle path
                let fillRect = CGRect(
                    x: blobBounds.minX - 10,
                    y: fillY,
                    width: blobBounds.width + 20,
                    height: blobBounds.maxY - fillY + 10
                )

                // Get colors based on progress
                let primaryColor = BlobColors.primary(for: progress)
                let accentColor = BlobColors.accent(for: progress)
                let deepColor = BlobColors.deep(for: progress)

                // Create clipped context for the fill
                var clippedContext = context
                clippedContext.clip(to: blobSwiftPath)

                // Draw the fill gradient
                let fillGradient = Gradient(stops: [
                    .init(color: accentColor.opacity(0.95), location: 0.0),
                    .init(color: primaryColor, location: 0.4),
                    .init(color: deepColor, location: 1.0)
                ])

                clippedContext.fill(
                    Path(fillRect),
                    with: .linearGradient(
                        fillGradient,
                        startPoint: CGPoint(x: center.x, y: fillY),
                        endPoint: CGPoint(x: center.x, y: blobBounds.maxY)
                    )
                )

                // Add subtle highlight at the fill surface (liquid surface effect)
                let highlightRect = CGRect(
                    x: blobBounds.minX - 10,
                    y: fillY,
                    width: blobBounds.width + 20,
                    height: min(12, blobBounds.maxY - fillY)
                )

                clippedContext.fill(
                    Path(highlightRect),
                    with: .linearGradient(
                        Gradient(colors: [
                            accentColor.opacity(0.7),
                            accentColor.opacity(0.0)
                        ]),
                        startPoint: CGPoint(x: center.x, y: fillY),
                        endPoint: CGPoint(x: center.x, y: fillY + 12)
                    )
                )
            }
        }
    }

    // MARK: - Blob Shape Generation

    /// Creates an organic blob path with control points
    private func createBlobPath(center: CGPoint, baseRadius: CGFloat, time: TimeInterval) -> UIBezierPath {
        let path = UIBezierPath()
        let points = 6  // Number of blob "bumps"

        // Generate control points with subtle organic variation
        var controlPoints: [CGPoint] = []

        for i in 0..<points {
            let angle = (Double(i) / Double(points)) * .pi * 2

            // Static organic variation (seeded by point index)
            let variation1 = Darwin.sin(Double(i) * 0.8) * 0.05
            let variation2 = Darwin.cos(Double(i) * 1.2) * 0.03
            let radiusMultiplier = 1.0 + variation1 + variation2

            let r = baseRadius * radiusMultiplier
            let x = center.x + Darwin.cos(angle) * r
            let y = center.y + Darwin.sin(angle) * r

            controlPoints.append(CGPoint(x: x, y: y))
        }

        guard !controlPoints.isEmpty else { return path }

        // Start at midpoint between last and first point
        let startPoint = midpoint(controlPoints[points - 1], controlPoints[0])
        path.move(to: startPoint)

        for i in 0..<points {
            let current = controlPoints[i]
            let next = controlPoints[(i + 1) % points]
            let endPoint = midpoint(current, next)

            path.addQuadCurve(to: endPoint, controlPoint: current)
        }

        path.close()
        return path
    }

    /// Calculates midpoint between two points
    private func midpoint(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }

    // MARK: - Breathing Animation

    /// Calculates the breathing scale effect
    private func breatheScale(time: TimeInterval) -> CGFloat {
        guard !reduceMotion else { return 1.0 }

        // Primary breathing: slow 4.5 second cycle
        let primary = Darwin.sin(time * (2 * .pi / 4.5)) * 0.02

        // Secondary micro-movement: offset 2.8 second cycle for organic feel
        let secondary = Darwin.sin(time * (2 * .pi / 2.8) + 1.2) * 0.01

        return 1.0 + primary + secondary
    }
}

// MARK: - Preview

#Preview("Progress Levels") {
    VStack(spacing: 30) {
        HStack(spacing: 20) {
            VStack {
                BreathingBlobView(progress: 0.0)
                    .frame(width: 100, height: 100)
                Text("0%").font(.caption)
            }
            VStack {
                BreathingBlobView(progress: 0.25)
                    .frame(width: 100, height: 100)
                Text("25%").font(.caption)
            }
            VStack {
                BreathingBlobView(progress: 0.5)
                    .frame(width: 100, height: 100)
                Text("50%").font(.caption)
            }
        }
        HStack(spacing: 20) {
            VStack {
                BreathingBlobView(progress: 0.75)
                    .frame(width: 100, height: 100)
                Text("75%").font(.caption)
            }
            VStack {
                BreathingBlobView(progress: 1.0)
                    .frame(width: 100, height: 100)
                Text("100%").font(.caption)
            }
            VStack {
                BreathingBlobView(progress: 1.2)
                    .frame(width: 100, height: 100)
                Text("120%").font(.caption)
            }
        }
    }
    .padding()
}

#Preview("Large") {
    VStack(spacing: 40) {
        BreathingBlobView(progress: 0.6)
            .frame(width: 160, height: 160)

        BreathingBlobView(progress: 1.15)
            .frame(width: 160, height: 160)
    }
    .padding()
}
