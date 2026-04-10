//
//  MockConfigurationStorage.swift
//  ColorBotKids
//
//  Created by ksurikova on 17.11.2025.
//

final class MockConfigurationStorage: ConfigurationStorage {
    private var storage: AppConfiguration?
    private let shouldLoadConfig: Bool
    private let simulateCorruption: Bool

    init(
        shouldLoadConfig: Bool = true,
        simulateCorruption: Bool = false,
        currentConfiguration: AppConfiguration? = nil
    ) {
        self.shouldLoadConfig = shouldLoadConfig
        self.simulateCorruption = simulateCorruption
        storage = currentConfiguration
    }

    func loadConfiguration() throws -> AppConfiguration {
        if !shouldLoadConfig {
            // Simulate missing configuration (first launch scenario)
            return AppConfiguration(aiConfig: nil, speechConfig: nil)
        }
        if simulateCorruption {
            // Simulate corrupted saved data
            throw ConfigurationError.corruptedData
        }

        // Return a configuration
        return storage ?? AppConfiguration(aiConfig: nil, speechConfig: nil)
    }

    func saveAIConfiguration(_ config: AIConfiguration) throws {
        var current = storage ?? AppConfiguration(
            aiConfig: AIConfiguration(provider: config.provider, apiKey: config.apiKey),
            speechConfig: SpeechConfiguration(
                language: "en",
                useOnlyOnDevice: false,
                autoPlayConfirmation: false
            )
        )
        current.aiConfig = config
        storage = current
    }

    func saveSpeechConfiguration(_ config: SpeechConfiguration) throws {
        var current = storage ?? AppConfiguration(
            aiConfig: AIConfiguration(provider: .mock, apiKey: "no-key-needed"),
            speechConfig: SpeechConfiguration(
                language: config.language,
                useOnlyOnDevice: config.useOnlyOnDevice,
                autoPlayConfirmation: config.autoPlayConfirmation
            )
        )
        current.speechConfig = config
        storage = current
    }

    func saveAllConfigurations(ai: AIConfiguration, speech: SpeechConfiguration) throws {
        let current = AppConfiguration(
            aiConfig: AIConfiguration(provider: ai.provider, apiKey: ai.apiKey),
            speechConfig: SpeechConfiguration(
                language: speech.language,
                useOnlyOnDevice: speech.useOnlyOnDevice,
                autoPlayConfirmation: speech.autoPlayConfirmation
            )
        )
        storage = current
    }

    func deleteAll() throws {
        if storage == nil {
            throw ConfigurationError.failedToDelete
        }
        storage = nil
    }
}
