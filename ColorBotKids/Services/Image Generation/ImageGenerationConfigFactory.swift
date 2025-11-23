//
//  ImageGenerationConfigFactory.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//
enum ImageGenerationConfigFactory {
    static func createConfig(for provider: ImageProvider, apiKey: String) -> ImageGenerationConfig {
        switch provider {
        case .stabilityAI:
            return StabilityAIConfig(apiKey: apiKey)
        case .openAI:
            return OpenAIConfig(apiKey: apiKey)
        case .mock:
            return MockConfig()
        }
    }
}
