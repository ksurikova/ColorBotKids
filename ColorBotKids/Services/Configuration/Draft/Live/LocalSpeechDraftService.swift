//
//  LocalSpeechDraftService.swift
//  ColorBotKids
//
//  Created by ksurikova on 9.03.2026.
//
import Foundation

final class LocalSpeechDraftService: SpeechConfigurationDraftService {
    private let defaults: UserDefaults

    private enum Keys {
        static let language = "draft_speech_language"
        static let useOnlyOnDevice = "draft_speech_useOnlyOnDevice"
        static let autoPlayConfirmation = "draft_speech_autoPlayConfirmation"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadDraft() -> SpeechConfiguration? {
        guard let language = defaults.string(forKey: Keys.language) else {
            return nil
        }

        let useOnlyOnDevice = defaults.bool(forKey: Keys.useOnlyOnDevice)
        let autoPlayConfirmation = defaults.bool(forKey: Keys.autoPlayConfirmation)

        return SpeechConfiguration(
            language: language,
            useOnlyOnDevice: useOnlyOnDevice,
            autoPlayConfirmation: autoPlayConfirmation
        )
    }

    func saveDraft(_ config: SpeechConfiguration) {
        defaults.set(config.language, forKey: Keys.language)
        defaults.set(config.useOnlyOnDevice, forKey: Keys.useOnlyOnDevice)
        defaults.set(config.autoPlayConfirmation, forKey: Keys.autoPlayConfirmation)
    }

    func clearDraft() {
        defaults.removeObject(forKey: Keys.language)
        defaults.removeObject(forKey: Keys.useOnlyOnDevice)
        defaults.removeObject(forKey: Keys.autoPlayConfirmation)
    }
}
