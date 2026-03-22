//
//  SettingsViewModel.swift
//  ColorBotKids
//
//  Created by ksurikova on 20.02.2026.
//
import Combine
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Children

    // Exposed so the View can pass them to child views
    let aiViewModel: AIConfigurationViewModel
    let speechViewModel: SpeechConfigurationViewModel

    // MARK: Dependencies

    private let configManager: ConfigurationManager
    let permissionManager: PermissionManager
    let draftService: SpeechConfigurationDraftService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Output State

    @Published private(set) var isSaving = false
    @Published private(set) var error: AppError?
    @Published private(set) var canSave: Bool = false // Now reactive

    init(
        configManager: ConfigurationManager,
        permissionManager: PermissionManager,
        draftService: SpeechConfigurationDraftService
    ) {
        self.configManager = configManager
        self.permissionManager = permissionManager
        self.draftService = draftService
        // Initialize Children
        aiViewModel = AIConfigurationViewModel(configManager: configManager)

        // Use .settings mode: Don't block saving just because microphone permission is missing
        speechViewModel = SpeechConfigurationViewModel(
            configManager: configManager,
            permissionManager: permissionManager,
            draftService: draftService,
            mode: .settings
        )

        setupPipeline()
    }

    private func setupPipeline() {
        // The Save button is enabled if BOTH sections are valid
        // (Assuming we want to ensure everything is correct before a unified save)
        Publishers.CombineLatest(aiViewModel.$selectedProvider, speechViewModel.$canSave)
            .map { [weak self] _, speechValid in
                guard let self = self else { return false }
                // Accessing AI validation logic (you might add a similar isValid property to AI VM)
                return self.aiViewModel.isValid && speechValid
            }
            .assign(to: &$canSave)

        // Observe errors from children
        aiViewModel.$error.compactMap { $0 }.assign(to: &$error)
        speechViewModel.$error.compactMap { $0 }.assign(to: &$error)
    }

    // MARK: Intentions

    func dismissError() {
        error = nil
        aiViewModel.dismissError()
        speechViewModel.dismissError()
    }

    // MARK: - User Actions

    // Call this when User taps "Cancel"
    func discardChanges() {
        speechViewModel.clearDrafts()
    }

    // MARK: - Unified Save Strategy

    func save() {
        guard canSave else { return }
        isSaving = true
        error = nil

        // Build Configs using the logic inside Child ViewModels
        guard let speechConfig = speechViewModel.buildConfiguration(),
              let aiConfig = aiViewModel.buildConfiguration()
        else {
            isSaving = false
            return
        }

        // Perform Save
        do {
            try configManager.saveAllConfigurations(ai: aiConfig, speech: speechConfig)
            // Save successful? Clear drafts now.
            speechViewModel.clearDrafts()
        } catch {
            self.error =
                (error as? AppError) ?? .configurationFailed(error.localizedDescription)
        }

        isSaving = false
    }
}
