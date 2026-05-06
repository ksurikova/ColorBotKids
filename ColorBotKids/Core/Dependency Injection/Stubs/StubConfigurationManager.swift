//
//  StubConfigurationManager.swift
//  ColorBotKids
//
//  Created by GitHub Copilot on 06.05.2026.
//

import Combine
import Foundation

final class StubConfigurationManager: ConfigurationManaging {
    var configuration: AppConfiguration
    var resolver: SpeechCapabilityResolving
    var configurationSaved: PassthroughSubject<Void, Never> = .init()

    var isFullyConfigured: Bool
    var isTTSEnabled: Bool
    var autoPlayConfirmation: Bool
    var currentSpeechCapabilities: SpeechCapabilities?

    init(
        configuration: AppConfiguration = AppConfiguration(),
        resolver: SpeechCapabilityResolving = SpeechCapabilityResolver(
            speechService: MockSpeechRecognitionService.self,
            ttsService: MockTextToSpeechService.self
        ),
        isFullyConfigured: Bool = true,
        isTTSEnabled: Bool = true,
        autoPlayConfirmation: Bool = true,
        currentSpeechCapabilities: SpeechCapabilities? = nil
    ) {
        self.configuration = configuration
        self.resolver = resolver
        self.isFullyConfigured = isFullyConfigured
        self.isTTSEnabled = isTTSEnabled
        self.autoPlayConfirmation = autoPlayConfirmation
        self.currentSpeechCapabilities = currentSpeechCapabilities
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

    func load() throws {}

    func saveSpeechConfiguration(_ config: SpeechConfiguration) throws {}

    func saveAllConfigurations(ai: AIConfiguration, speech: SpeechConfiguration) throws {}

    func saveAIConfiguration(_ config: AIConfiguration) throws {}

    func reset() throws {}
}
