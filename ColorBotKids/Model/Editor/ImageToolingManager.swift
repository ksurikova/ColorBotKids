import PencilKit
import SwiftUI
import UIKit

// Use this manager to encapsulate image manipulation logic
final class ImageToolingManager {
    private let drawService: DrawService
    private let saveService: ImageSaveService

    init(
        drawService: DrawService,
        saveService: ImageSaveService
    ) {
        self.drawService = drawService
        self.saveService = saveService
    }

    func saveImage(baseImage: UIImage, canvasView: PKCanvasView) async throws -> UIImage {
        // Combine layers
        let finalImage = drawService.combineImageWithDrawing(baseImage, canvasView: canvasView)
        // Save to library
        try await saveService.saveImageToPhotoLibrary(finalImage)
        return finalImage
    }
}
