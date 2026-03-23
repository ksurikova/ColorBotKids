//
//  MockAIConfigurationDraftService.swift
//  ColorBotKids
//
//  Created by ksurikova on 06.03.2026.
//

import Foundation

final class MockAIConfigurationDraftService: AIConfigurationDraftService {
    var storedDraft: AIConfiguration?

    init(initialDraft: AIConfiguration? = nil) {
        storedDraft = initialDraft
    }

    func loadDraft() -> AIConfiguration? {
        storedDraft
    }

    func saveDraft(_ config: AIConfiguration) {
        storedDraft = config
    }

    func clearDraft() {
        storedDraft = nil
    }
}
