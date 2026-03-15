//
//  AIConfigurationViewModel.swift
//  ColorBotKids
//
//  Created by ksurikova on 4.03.2026.
//
import Combine
import SwiftUI

@MainActor
final class AIConfigurationViewModel: ObservableObject {
    // MARK: - Dependencies

    private let configManager: ConfigurationManager

    // MARK: - Draft State

    @Published var selectedProvider: ImageProvider = .mock
    @Published var apiKey: String = ""

    // MARK: - Output State

    @Published private(set) var error: AppError?
    @Published private(set) var isSaving: Bool = false

    var requiresApiKey: Bool {
        selectedProvider != .mock
    }

    var isValid: Bool {
        !requiresApiKey || !apiKey.isEmpty
    }

    var apiKeyFooterText: LocalizedStringKey? {
        guard requiresApiKey else { return nil }
        switch selectedProvider {
        case .openAI: return "onboarding_footer_openai_apiKey"
        case .stabilityAI: return "onboarding_footer_stability_apiKey"
        case .mock: return nil
        }
    }

    // MARK: - Initialization

    init(configManager: ConfigurationManager) {
        self.configManager = configManager

        // Load initial state
        let currentConfig = configManager.configuration.aiConfig
        selectedProvider = currentConfig?.provider ?? .mock
        apiKey = currentConfig?.apiKey ?? ""
    }

    // MARK: - Intents

    func dismissError() {
        error = nil
    }

    func save() {
        guard let config = buildConfiguration() else { return }

        isSaving = true
        error = nil

        do {
            try configManager.saveAIConfiguration(config)
        } catch {
            self.error = (error as? AppError) ?? .configurationFailed(error.localizedDescription)
        }
        isSaving = false
    }

    // MARK: - Public API for Parents

    func buildConfiguration() -> AIConfiguration? {
        guard isValid else { return nil }
        let keyToSave = requiresApiKey ? apiKey : AppConstants.mockAPIKey
        return AIConfiguration(provider: selectedProvider, apiKey: keyToSave)
    }

    // Call this when the view disappears to reset the key if the provider doesn't need it,
    // or bind it to the picker change.
    func sanitizeState() {
        if !requiresApiKey {
            apiKey = ""
        }
    }
}
