//
//  FittingImageView.swift
//  ColorBotKids
//
//  Created by ksurikova on 25.10.2025.
//
import SwiftUI

struct FittingImageView: View {
    let image: UIImage
    let canvasSize: CGSize
    @Binding var displaySize: CGSize

    // Cache the computed fit size
    private var fitSize: CGSize {
        let imageSize = image.size
        let aspectRatio = imageSize.width / imageSize.height
        return CGSize.computeFitSize(canvasSize: canvasSize, aspectRatio: aspectRatio)
    }

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .frame(width: fitSize.width, height: fitSize.height)
            .task(id: canvasSize) {
                // Update display size whenever canvas size changes
                displaySize = fitSize
            }
            .frame(width: canvasSize.width, height: canvasSize.height)
            .clipped()
    }
}

#Preview {
    FittingImageView(image: UIImage(named: "PreviewDefaultImage")!,
                     canvasSize: CGSize(width: 200, height: 200),
                     displaySize: .constant(CGSize(width: 0, height: 0)))
}

// MARK: todo move to special Extension file

extension UIImage {
    func normalized() -> UIImage {
        guard imageOrientation != .up else {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

extension CGSize {
    static func computeFitSize(canvasSize: CGSize, aspectRatio: CGFloat) -> CGSize {
        // Validate inputs
        guard aspectRatio.isFinite, aspectRatio > 0,
              canvasSize.width.isFinite, canvasSize.width > 0,
              canvasSize.height.isFinite, canvasSize.height > 0
        else {
            return .zero
        }

        let containerAspectRatio = canvasSize.width / canvasSize.height

        let width: CGFloat
        let height: CGFloat

        if aspectRatio > containerAspectRatio {
            // Image is wider than container - fit to width
            width = canvasSize.width
            height = width / aspectRatio
        } else {
            // Image is taller than container - fit to height
            height = canvasSize.height
            width = height * aspectRatio
        }

        // Ensure we don't exceed canvas bounds (defensive programming)
        return CGSize(
            width: min(width, canvasSize.width),
            height: min(height, canvasSize.height)
        )
    }
}
