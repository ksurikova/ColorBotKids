//
//  MainServicesFactory.swift
//  ColorBotKids
//
//  Created by ksurikova on 9.02.2026.
//
import Foundation

struct MainServiceFactory {
    private let imageGenerationServiceFactory: ImageGenerationServiceFactory

    init(
        imageGenerationServiceFactory: ImageGenerationServiceFactory
    ) {
        self.imageGenerationServiceFactory = imageGenerationServiceFactory
    }

    func createServices(
        configuration: AppConfiguration,
        resolver: SpeechCapabilityResolver
    ) throws -> AppMainServices {
        guard let aiConfig = configuration.aiConfig else {
            throw ConfigurationError.aiConfigurationMissing
        }

        guard let speechConfig = configuration.speechConfig else {
            throw ConfigurationError.speechConfigurationMissing
        }

        // Check if the configuration is fundamentally valid (critical check)
        let capabilities = resolver.resolve(from: speechConfig)
        guard capabilities.isCriticalValid else {
            throw ConfigurationError.speechConfigurationInvalid
        }

        // Get safe, resolved settings from the resolver
        let (speechSettings, ttsSettings) = resolver.resolveSettings(from: speechConfig)

        // Create Speech Recognition Service
        // Use the EXACT service type that the resolver verified
        let speechRecognition = try resolver.speechService.init(settings: speechSettings)

        // Create Text-to-Speech Service (Optional)
        let textToSpeech: TextToSpeechService?
        if let ttsSettings = ttsSettings {
            // Use the EXACT service type that the resolver verified
            textToSpeech = resolver.ttsService.init(settings: ttsSettings)
        } else {
            textToSpeech = nil
        }

        // Create Image Generation Service
        let imageGeneration = imageGenerationServiceFactory.make(for: aiConfig)

        return AppMainServices(
            speechRecognition: speechRecognition,
            textToSpeech: textToSpeech,
            imageGeneration: imageGeneration
        )
    }
}
