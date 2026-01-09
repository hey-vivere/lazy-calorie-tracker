//
//  QuickActionButton.swift
//  lct
//
//  Created by Claude on 01/09/26.
//

import SwiftUI

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                Text(title)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 16) {
        QuickActionButton(
            icon: "camera.fill",
            title: "Camera",
            color: .blue
        ) {}

        QuickActionButton(
            icon: "pencil.line",
            title: "Manual",
            color: .green
        ) {}
    }
    .padding()
}
