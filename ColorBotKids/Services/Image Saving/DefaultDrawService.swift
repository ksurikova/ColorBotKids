//
//  DefaultDrawService.swift
//  ColorBotKids
//
//  Created by ksurikova on 13.11.2025.
//
import PencilKit
import SwiftUI

final class DefaultDrawService: DrawService {
    func combineImageWithDrawing(
        _ image: UIImage,
        canvasView: PKCanvasView
    ) -> UIImage {
        let fixedImage = image.normalized()
        let originalImageSize = fixedImage.size

        // Render canvas to image at canvas size
        // Let’s use this exact view to render the drawing as a rasterized image.
        let renderedDrawing = renderCanvasView(canvasView, at: originalImageSize)

        // Begin new image context
        UIGraphicsBeginImageContextWithOptions(originalImageSize, false, fixedImage.scale)
        defer { UIGraphicsEndImageContext() }

        // Draw base image
        fixedImage.draw(in: CGRect(origin: .zero, size: originalImageSize))

        // Overlay drawing
        renderedDrawing.draw(in: CGRect(origin: .zero, size: originalImageSize))

        // Save composited image
        let final = UIGraphicsGetImageFromCurrentImageContext() ?? fixedImage
        return final
    }

    private func renderCanvasView(_ canvas: PKCanvasView, at size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            // Scale the drawing to match the target size
            let scaleX = size.width / canvas.bounds.width
            let scaleY = size.height / canvas.bounds.height

            context.cgContext.scaleBy(x: scaleX, y: scaleY)

            // Use PKDrawing's image method which properly renders all tool types
            let drawingImage = canvas.drawing.image(from: canvas.bounds, scale: format.scale)
            drawingImage.draw(in: canvas.bounds)
        }
    }
}
