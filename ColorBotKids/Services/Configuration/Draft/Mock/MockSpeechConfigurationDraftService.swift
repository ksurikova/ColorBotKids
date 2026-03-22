//
//  MockSpeechConfigurationDraftService.swift
//  ColorBotKids
//
//  Created by ksurikova on 18.03.2026.
//

import Foundation

final class MockSpeechConfigurationDraftService: SpeechConfigurationDraftService {
    var draft: SpeechConfiguration?

    init(draft: SpeechConfiguration? = nil) {
        self.draft = draft
    }

    func loadDraft() -> SpeechConfiguration? {
        draft
    }

    func saveDraft(_ config: SpeechConfiguration) {
        draft = config
    }

    func clearDraft() {
        draft = nil
    }
}
