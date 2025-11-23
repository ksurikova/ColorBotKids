//
//  ImageGenerationService.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//
import SwiftUI

protocol ImageGenerationService {
    func generateImage(from prompt: String) async throws -> UIImage
}

private struct ImageGenerationServiceKey: EnvironmentKey {
    static let defaultValue: ImageGenerationService =
        MockImageGenerationService(config: MockConfig())
}

extension EnvironmentValues {
    var imageGenerationService: ImageGenerationService {
        get { self[ImageGenerationServiceKey.self] }
        set { self[ImageGenerationServiceKey.self] = newValue }
    }
}
