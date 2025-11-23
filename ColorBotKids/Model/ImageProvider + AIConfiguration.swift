//
//  ImageProvider.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//
enum ImageProvider: String, Codable, CaseIterable {
    case stabilityAI = "Stability AI"
    case openAI = "OpenAI DALL-E"
    case mock = "Mock (Testing)"

    var displayName: String { rawValue }
}

struct AIConfiguration: Codable, Equatable {
    let provider: ImageProvider
    let apiKey: String
}

extension AIConfiguration {
    var isValid: Bool {
        switch provider {
        case .mock:
            return true
        case .stabilityAI:
            // Stability AI keys start with "sk-"
            return apiKey.hasPrefix("sk-") && apiKey.count > 20
        case .openAI:
            // OpenAI keys start with "sk-"
            return apiKey.hasPrefix("sk-") && apiKey.count > 20
        }
    }

    var validationError: String? {
        guard provider != .mock else { return nil }
        if apiKey.isEmpty {
            return "API key is required"
        }
        if !isValid {
            return "API key format looks incorrect for \(provider.displayName)"
        }
        return nil
    }

    func toImageGenerationConfig() -> ImageGenerationConfig {
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
