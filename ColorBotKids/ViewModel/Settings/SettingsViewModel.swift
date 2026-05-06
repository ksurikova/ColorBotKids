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

    let aiViewModel: AIConfigurationViewModel
    let speechViewModel: SpeechConfigurationViewModel
    let photoViewModel: PhotoLibraryViewModel
    let configurationManager: ConfigurationManaging

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Output State

    @Published private(set) var isSaving = false
    @Published private(set) var error: AppError?
    @Published private(set) var canSave: Bool = false // Now reactive

    init(
        aiViewModel: AIConfigurationViewModel,
        speechViewModel: SpeechConfigurationViewModel,
        photoViewModel: PhotoLibraryViewModel,
        configurationManager: ConfigurationManaging
    ) {
        self.aiViewModel = aiViewModel
        self.speechViewModel = speechViewModel
        self.photoViewModel = photoViewModel
        self.configurationManager = configurationManager

        setupPipeline()
    }

    private func setupPipeline() {
        // The Save button is enabled if BOTH sections are valid
        // (Assuming we want to ensure everything is correct before a unified save)
        Publishers.CombineLatest(
            aiViewModel.$selectedProvider,
            speechViewModel.$state.map { $0.content.canSave }
        )
        .map { [weak self] _, speechValid in
            guard let self = self else { return false }
            // Accessing AI validation logic (you might add a similar isValid property to AI VM)
            return self.aiViewModel.isValid && speechValid
        }
        .assign(to: &$canSave)

        // Observe errors from children
        aiViewModel.$error.compactMap { $0 }.assign(to: &$error)

        speechViewModel.$state
            .compactMap { $0.error }
            .assign(to: &$error)
    }

    // MARK: Intentions

    func dismissError() {
        error = nil
        aiViewModel.dismissError()
        speechViewModel.dismissError()
    }

    // MARK: - User Actions

    // Call this when User taps "Cancel" or swipes away
    func discardChanges() {
        speechViewModel.clearDrafts()
        aiViewModel.clearDrafts()
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
            try configurationManager.saveAllConfigurations(ai: aiConfig, speech: speechConfig)
            // No need to clear drafts here, onDisappear will handle it upon dismissal
        } catch {
            self.error = error.asAppError
        }

        isSaving = false
    }
}
