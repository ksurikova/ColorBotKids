//
//  ImageCanvasView.swift
//  ColorBotKids
//
//  Created by ksurikova on 25.10.2025.
//
import PencilKit
import SwiftUI

struct ImageCanvasView: View {
    let image: UIImage
    @Binding var canvasView: PKCanvasView
    let drawingData: Data?
    @State private var displaySize: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image - scales to fit available space
                FittingImageView(
                    image: image,
                    canvasSize: geometry.size,
                    displaySize: $displaySize
                )

                // Drawing canvas overlay - matches image size exactly
                DrawingCanvasContainerView(
                    canvasView: $canvasView,
                    existingDrawingData: drawingData,
                    displaySize: displaySize
                )
                .frame(width: displaySize.width, height: displaySize.height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview() {
    ImageCanvasView(
        image: UIImage(named: "defaultImage")!,
        canvasView: Binding.constant(PKCanvasView()),
        drawingData: Data()
    )
}
