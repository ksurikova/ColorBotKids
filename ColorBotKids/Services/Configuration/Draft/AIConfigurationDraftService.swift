//
//  AIConfigurationDraftService.swift
//  ColorBotKids
//
//  Created by ksurikova on 06.03.2026.
//

import Foundation

protocol AIConfigurationDraftService {
    func loadDraft() -> AIConfiguration?
    func saveDraft(_ config: AIConfiguration)
    func clearDraft()
}
