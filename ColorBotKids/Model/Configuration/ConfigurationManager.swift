//
//  ConfigurationManager.swift
//  ColorBotKids
//
//  Created by ksurikova on 17.10.2025.
//
import Combine
import Foundation

final class ConfigurationManager {
    private(set) var configuration: AppConfiguration

    private let storage: ConfigurationStorage
    let resolver: SpeechCapabilityResolver

    let configurationSaved = PassthroughSubject<Void, Never>()

    // Derived property for UI to know current capabilities
    var currentSpeechCapabilities: SpeechCapabilities? {
        guard let speechConfig = configuration.speechConfig else { return nil }
        return resolver.resolve(from: speechConfig)
    }

    var isFullyConfigured: Bool {
        guard let speechConfig = configuration.speechConfig else { return false }
        let caps = resolver.resolve(from: speechConfig)
        return configuration.aiConfig != nil && caps.isCriticalValid
    }

    var isTTSEnabled: Bool {
        guard let caps = currentSpeechCapabilities else { return false }
        return caps.ttsAvailable
    }

    var autoPlayConfirmation: Bool {
        configuration.speechConfig?.autoPlayConfirmation ?? false
    }

    init(storage: ConfigurationStorage, resolver: SpeechCapabilityResolver) {
        self.storage = storage
        self.resolver = resolver
        configuration = AppConfiguration()
    }

    func getCapableLocales() -> [Locale] {
        resolver.getCapableLocales()
    }

    func resolveCapabilities(for config: SpeechConfiguration) -> SpeechCapabilities {
        resolver.resolve(from: config)
    }

    func resolveCapabilities(for locale: Locale) -> SpeechCapabilities {
        resolver.resolve(for: locale)
    }

    func getInitialLocale() -> Locale {
        resolver.resolveLocale(locale: nil)
    }

    func load() {
        do {
            configuration = try storage.loadConfiguration()
        } catch {
            configuration = AppConfiguration()
        }
    }

    func saveSpeechConfiguration(_ config: SpeechConfiguration) throws {
        // Validate critical requirements before saving
        let capabilities = resolver.resolve(from: config)
        guard capabilities.isCriticalValid else {
            throw ConfigurationError.speechConfigurationInvalid
        }

        try storage.saveSpeechConfiguration(config)
        configuration.speechConfig = config
        // tell listeners about it
        configurationSaved.send()
    }

    func saveAllConfigurations(
        ai: AIConfiguration,
        speech: SpeechConfiguration
    ) throws {
        // Validate critical requirements before saving
        let capabilities = resolver.resolve(from: speech)
        guard capabilities.isCriticalValid else {
            throw ConfigurationError.speechConfigurationInvalid
        }

        // Save both configurations atomically
        try storage.saveAllConfigurations(ai: ai, speech: speech)

        // Update in-memory state only after successful save
        configuration.aiConfig = ai
        configuration.speechConfig = speech

        // tell listeners about it
        configurationSaved.send()
    }

    func saveAIConfiguration(_ config: AIConfiguration) throws {
        try storage.saveAIConfiguration(config)
        configuration.aiConfig = config
        // tell listeners about it
        configurationSaved.send()
    }

    func reset() throws {
        try storage.deleteAll()
        configuration = AppConfiguration()
    }
}
