//
//  QuickCaptureFlow.swift
//  lct
//
//  Created by Claude on 1/9/26.
//

import SwiftUI

struct QuickCaptureFlow: View {
    @Binding var isPresented: Bool

    @State private var capturedImage: UIImage?

    var body: some View {
        Group {
            if let image = capturedImage {
                MealDescriptionView(image: image, isPresented: $isPresented)
            } else {
                PhotoCaptureView { image in
                    capturedImage = image
                }
            }
        }
    }
}

#Preview {
    QuickCaptureFlow(isPresented: .constant(true))
        .environmentObject(MealsStore.mock)
}
