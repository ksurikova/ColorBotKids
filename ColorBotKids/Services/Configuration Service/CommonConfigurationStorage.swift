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
        let provider = defaults.string(forKey: Keys.provider)
            .flatMap { ImageProvider(rawValue: $0) }
        let apiKey = try? keychain.read(key: Keys.apiKeyIdentifier)
        let aiConfig: AIConfiguration? = if let provider, let apiKey {
            AIConfiguration(provider: provider, apiKey: apiKey)
        } else {
            nil
        }
        let language = defaults.string(forKey: Keys.speechLanguage)
        let recognizeOnlyOnDevice = defaults.bool(forKey: Keys.recognizeOnlyOnDevice)
        let autoPlayConfirmation = defaults.bool(forKey: Keys.autoPlayConfirmation)
        let speechConfig: SpeechConfiguration? = if let language {
            SpeechConfiguration(
                language: language,
                useOnlyOnDevice: recognizeOnlyOnDevice,
                autoPlayConfirmation: autoPlayConfirmation
            )
        } else {
            nil
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
        try keychain.save(key: Keys.apiKeyIdentifier, value: config.apiKey)
    }

    func saveSpeechConfiguration(_ config: SpeechConfiguration) throws {
        defaults.set(config.language, forKey: Keys.speechLanguage)
    }

    func deleteAll() throws {
        defaults.removeObject(forKey: Keys.provider)
        defaults.removeObject(forKey: Keys.speechLanguage)
        try? keychain.delete(key: Keys.apiKeyIdentifier)
    }
}
