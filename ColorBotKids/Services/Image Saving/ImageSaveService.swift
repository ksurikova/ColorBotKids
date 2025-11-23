//
//  ImageSaveService.swift
//  ColorBotKids
//
//  Created by ksurikova on 13.11.2025.
//
import SwiftUI

protocol ImageSaveService {
    func saveImageToPhotoLibrary(_ image: UIImage) async throws
}

enum ImageSaveServiceError: LocalizedError {
    case noPermission
    case invalidImageToSave
    case savingIsInterrupted
    case unknownError(Error?)

    var errorDescription: String? {
        switch self {
        case .noPermission:
            return "Photo library access is required to save images. You can enable it in Settings or use other sharing options."
        case .invalidImageToSave:
            return "Unable to save the image. Image is corrupted."
        case .savingIsInterrupted:
            return "Unable to save the image. Saving process was interrupted."
        case let .unknownError(error):
            return "An unexpected error occurred: \(error?.localizedDescription ?? "unknown error"). Please try again."
        }
    }
}

final class MockImageSaveService: ImageSaveService {
    func saveImageToPhotoLibrary(_ image: UIImage) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}

private struct ImageSaveServiceKey: EnvironmentKey {
    static let defaultValue: ImageSaveService = MockImageSaveService()
}

extension EnvironmentValues {
    var imageSaveService: ImageSaveService {
        get { self[ImageSaveServiceKey.self] }
        set { self[ImageSaveServiceKey.self] = newValue }
    }
}
