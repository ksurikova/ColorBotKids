//
//  ImageGenerationServiceFactory.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//
enum ImageGenerationServiceFactory {
    static func createService(config: ImageGenerationConfig) -> ImageGenerationService {
        switch config {
        case is StabilityAIConfig:
            return HTTPImageService(config: config)
        case is OpenAIConfig:
            return HTTPImageService(config: config)
        case is MockConfig:
            return MockImageGenerationService(config: config)
        default:
            return MockImageGenerationService(config: config)
        }
    }

    static func createService(from aiConfig: AIConfiguration) -> ImageGenerationService {
        let config = aiConfig.toImageGenerationConfig()
        return createService(config: config)
    }
}
