//
//  CommonConfigurationStorage.swift
//  ColorBotKids
//
//  Created by ksurikova on 21.10.2025.
//

import Foundation

final class CommonConfigurationStorage: ConfigurationStorage {
    private let defaults = UserDefaults.standard
    private let keychain = KeychainHelper() // keychain wrapper

    private enum Keys {
        static let provider = "ai_provider"
        static let speechLanguage = "speech_language"
        static let recognizeOnlyOnDevice = "speech_recognizeOnlyOnDevice"
        static let autoPlayConfirmation = "text_to_speech_autoPlayConfirmation"
        static let apiKeyIdentifier = "ai_api_key"
    }

    func loadConfiguration() throws -> AppConfiguration {
        let providerString = defaults.string(forKey: Keys.provider)
        let provider = providerString.flatMap { ImageProvider(rawValue: $0) }

        let apiKey: String?
        do {
            apiKey = try keychain.read(key: Keys.apiKeyIdentifier)
        } catch {
            apiKey = nil // Keep as nil, we validate completeness below
        }

        let aiConfig: AIConfiguration?
        if let provider {
            guard let apiKey else {
                throw ConfigurationError.corruptedData
            }
            aiConfig = AIConfiguration(provider: provider, apiKey: apiKey)
        } else if apiKey != nil {
            throw ConfigurationError.corruptedData
        } else {
            aiConfig = nil
        }

        let language = defaults.string(forKey: Keys.speechLanguage)
        let recognizeOnlyOnDevice = defaults.bool(forKey: Keys.recognizeOnlyOnDevice)
        let autoPlayConfirmation = defaults.bool(forKey: Keys.autoPlayConfirmation)

        let speechConfig: SpeechConfiguration?
        if let language {
            speechConfig = SpeechConfiguration(
                language: language,
                useOnlyOnDevice: recognizeOnlyOnDevice,
                autoPlayConfirmation: autoPlayConfirmation
            )
        } else {
            speechConfig = nil
        }

        return AppConfiguration(
            aiConfig: aiConfig,
            speechConfig: speechConfig
        )
    }

    func saveAIConfiguration(_ config: AIConfiguration) throws {
        // Save non-sensitive data to UserDefaults
        defaults.set(config.provider.rawValue, forKey: Keys.provider)
        // Save sensitive data to Keychain
        do {
            try keychain.save(key: Keys.apiKeyIdentifier, value: config.apiKey)
        } catch {
            throw ConfigurationError.failedToSave
        }
    }

    func saveSpeechConfiguration(_ config: SpeechConfiguration) throws {
        defaults.set(config.language, forKey: Keys.speechLanguage)
    }

    func saveAllConfigurations(ai: AIConfiguration, speech: SpeechConfiguration) throws {
        // Save all at once - if one fails, none are saved
        // This is more atomic and efficient
        // AI Configuration
        defaults.set(ai.provider.rawValue, forKey: Keys.provider)
        do {
            try keychain.save(key: Keys.apiKeyIdentifier, value: ai.apiKey)
        } catch {
            throw ConfigurationError.failedToSave
        }

        // Speech Configuration
        defaults.set(speech.language, forKey: Keys.speechLanguage)

        // Synchronize UserDefaults once at the end (optional but good practice)
        defaults.synchronize()
    }

    func deleteAll() throws {
        defaults.removeObject(forKey: Keys.provider)
        defaults.removeObject(forKey: Keys.speechLanguage)
        do {
            try keychain.delete(key: Keys.apiKeyIdentifier)
        } catch {
            throw ConfigurationError.failedToDelete
        }
    }
}
