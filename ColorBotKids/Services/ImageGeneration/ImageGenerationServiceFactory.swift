import SwiftUI

//
//  ImageGenerationServiceFactory.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//
protocol ImageGenerationServiceFactory {
    func make(for config: AIConfiguration) -> ImageGenerationService
}

struct LiveImageGenerationServiceFactory: ImageGenerationServiceFactory {
    func make(for config: AIConfiguration) -> ImageGenerationService {
        let generationConfig = config.toImageGenerationConfig()
        switch config.provider {
        case .openAI, .stabilityAI:
            return HTTPImageService(config: generationConfig)
        case .mock:
            return MockImageGenerationService(config: generationConfig)
        }
    }
}

// factory to improve mock reliability by forcing mock service regardless of config
struct ForcedMockImageGenerationServiceFactory: ImageGenerationServiceFactory {
    func make(for config: AIConfiguration) -> ImageGenerationService {
        // Always return Mock service, even if config is for OpenAI/StabilityAI
        MockImageGenerationService(config: config.toImageGenerationConfig())
    }
}

private struct ImageGenerationServiceFactoryKey: EnvironmentKey {
    static let defaultValue: ImageGenerationServiceFactory = LiveImageGenerationServiceFactory()
}

extension EnvironmentValues {
    var imageGenerationServiceFactory: ImageGenerationServiceFactory {
        get { self[ImageGenerationServiceFactoryKey.self] }
        set { self[ImageGenerationServiceFactoryKey.self] = newValue }
    }
}
