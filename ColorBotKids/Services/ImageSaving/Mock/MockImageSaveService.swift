//
//  ImageSaveService.swift
//  ColorBotKids
//
//  Created by ksurikova on 13.11.2025.
//
import SwiftUI

final class MockImageSaveService: ImageSaveService {
    func saveImageToPhotoLibrary(_ image: UIImage) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
