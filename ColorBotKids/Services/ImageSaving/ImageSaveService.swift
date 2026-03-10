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

private struct ImageSaveServiceKey: EnvironmentKey {
    static let defaultValue: ImageSaveService = MockImageSaveService()
}

extension EnvironmentValues {
    var imageSaveService: ImageSaveService {
        get { self[ImageSaveServiceKey.self] }
        set { self[ImageSaveServiceKey.self] = newValue }
    }
}
