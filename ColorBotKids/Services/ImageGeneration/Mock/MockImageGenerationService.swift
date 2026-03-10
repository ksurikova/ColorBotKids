//
//  MockImageGenerationService.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//
import SwiftUI

final class MockImageGenerationService: ImageGenerationService {
    private let config: ImageGenerationConfig

    init(config: ImageGenerationConfig) {
        self.config = config
    }

    func generateImage(from prompt: String) async throws -> UIImage {
        let finalPrompt = config.promptBuilder.makePrompt(from: prompt)
        print("Generating image with prompt: \(finalPrompt)")

        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Return a placeholder image
        return UIImage(named: "defaultImage")!
    }
}
