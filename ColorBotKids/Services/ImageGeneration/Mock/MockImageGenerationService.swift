//
//  MockImageGenerationService.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//
import SwiftUI

final class MockImageGenerationService: ImageGenerationService {
    private let config: ImageGenerationConfig
    private let mockSymbols = ["photo", "camera", "sparkles", "wand.and.stars", "paintpalette"]

    init(config: ImageGenerationConfig) {
        self.config = config
    }

    func generateImage(from prompt: String) async throws -> UIImage {
        let symbol = mockSymbols.randomElement() ?? "photo"
        let config = UIImage.SymbolConfiguration(pointSize: 120, weight: .thin)

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return UIImage(systemName: symbol, withConfiguration: config) ??
            UIImage(named: "defaultImage")!
    }
}
