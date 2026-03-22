//
//  LocalAIDraftService.swift
//  ColorBotKids
//
//  Created by ksurikova on 06.03.2026.
//

import Foundation

final class LocalAIDraftService: AIConfigurationDraftService {
    private let defaults: UserDefaults

    private enum Keys {
        static let provider = "draft_ai_provider"
        static let apiKey = "draft_ai_apiKey"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadDraft() -> AIConfiguration? {
        guard let providerRaw = defaults.string(forKey: Keys.provider),
              let provider = ImageProvider(rawValue: providerRaw),
              let apiKey = defaults.string(forKey: Keys.apiKey)
        else {
            return nil
        }

        return AIConfiguration(provider: provider, apiKey: apiKey)
    }

    func saveDraft(_ config: AIConfiguration) {
        defaults.set(config.provider.rawValue, forKey: Keys.provider)
        defaults.set(config.apiKey, forKey: Keys.apiKey)
    }

    func clearDraft() {
        defaults.removeObject(forKey: Keys.provider)
        defaults.removeObject(forKey: Keys.apiKey)
    }
}
