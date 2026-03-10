//
//  SpeechConfigurationDraftService.swift
//  ColorBotKids
//
//  Created by ksurikova on 06.03.2026.
//

import Foundation

protocol SpeechConfigurationDraftService {
    func loadDraft() -> SpeechConfiguration?
    func saveDraft(_ config: SpeechConfiguration)
    func clearDraft()
}
