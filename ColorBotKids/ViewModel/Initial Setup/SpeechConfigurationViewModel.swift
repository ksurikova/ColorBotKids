//
//  SpeechConfigurationViewModel.swift
//  ColorBotKids
//
//  Created by ksurikova on 18.02.2026.
//
import Combine
import SwiftUI

@MainActor
final class SpeechConfigurationViewModel: ObservableObject {
    // MARK: - Types

    enum ConfigurationMode {
        case onboarding
        case settings
    }

    struct Content: Equatable {
        var capabilities: SpeechCapabilities?
        var missingPermissions: Bool = false
        var canSave: Bool = false
        var warningMessage: LocalizedStringKey?
    }

    enum ScreenState: Equatable {
        case loading
        case content(Content)
        case saving(Content)
        case error(AppError, Content)

        var content: Content {
            switch self {
            case .loading: return Content()
            case let .content(c), let .saving(c), let .error(_, c): return c
            }
        }

        var isSaving: Bool {
            if case .saving = self { return true }
            return false
        }

        var error: AppError? {
            if case let .error(err, _) = self { return err }
            return nil
        }
    }

    // MARK: - Dependencies

    private let configManager: ConfigurationManager
    private let draftService: SpeechConfigurationDraftService
    let permissionManager: PermissionManager
    private let mode: ConfigurationMode

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Input State (@Published)

    @Published var selectedLocale: Locale
    @Published var useOnlyOnDevice: Bool
    @Published var autoPlayConfirmation: Bool

    // MARK: - Output State

    @Published var state: ScreenState = .loading

    // MARK: - Computed Properties for the View

    // The list of locales the Picker should display.
    // Guarantees that 'selectedLocale' is always present to avoid blank UI.
    var pickerLocales: [Locale] {
        let supported = configManager.getCapableLocales()
        if !supported.contains(selectedLocale) {
            return [selectedLocale] + supported
        }
        return supported
    }

    var supportedLocales: [Locale] { configManager.getCapableLocales() }
    var canSave: Bool { state.content.canSave }

    // MARK: - Initialization

    init(
        configManager: ConfigurationManager,
        permissionManager: PermissionManager,
        draftService: SpeechConfigurationDraftService,
        mode: ConfigurationMode = .onboarding
    ) {
        self.configManager = configManager
        self.permissionManager = permissionManager
        self.draftService = draftService
        self.mode = mode

        // 1. Resolve Data (Draft > Live > Default)
        let savedConfig = draftService.loadDraft() ?? configManager.configuration.speechConfig
        let supported = configManager.getCapableLocales()

        let candidateLocale = savedConfig.map { Locale(identifier: $0.language) }
            ?? configManager.getInitialLocale()

        // 2. Auto-Fix: Ensure the initial selection is valid if possible
        if supported.contains(candidateLocale) {
            selectedLocale = candidateLocale
        } else {
            // Fallback to first supported, or keep candidate if list is empty (handled by UI
            // warning)
            selectedLocale = supported.first ?? candidateLocale
        }

        useOnlyOnDevice = savedConfig?.useOnlyOnDevice ?? false
        autoPlayConfirmation = savedConfig?.autoPlayConfirmation ?? false

        setupPipelines()
    }

    // MARK: - Pipelines

    private func setupPipelines() {
        // Pipeline 1: Watch Locale and Permissions to update UI state
        let capabilitiesPublisher = $selectedLocale
            .map { [configManager] in configManager.resolveCapabilities(for: $0) }

        let permissionsPublisher = Publishers.CombineLatest(
            permissionManager.microphone,
            permissionManager.speechRecognition
        )

        Publishers.CombineLatest(capabilitiesPublisher, permissionsPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] caps, perms in
                self?.handleStateUpdate(capabilities: caps, permissions: perms)
            }
            .store(in: &cancellables)

        // Pipeline 2: Auto-Save Drafts (Only in Settings Mode)
        if mode == .settings {
            Publishers.CombineLatest3($selectedLocale, $useOnlyOnDevice, $autoPlayConfirmation)
                .dropFirst() // Ignore the initial setup values
                .debounce(for: .seconds(0.5),
                          scheduler: DispatchQueue.main) // Prevent spamming disk
                .sink { [weak self] locale, device, autoPlay in
                    let config = SpeechConfiguration(
                        language: locale.identifier,
                        useOnlyOnDevice: device,
                        autoPlayConfirmation: autoPlay
                    )
                    self?.draftService.saveDraft(config)
                }
                .store(in: &cancellables)
        }
    }

    // MARK: - State Management

    private func handleStateUpdate(
        capabilities: SpeechCapabilities,
        permissions: (PermissionStatus, PermissionStatus)
    ) {
        // Auto-correct toggles if capabilities change (e.g. user picks a locale without On-Device
        // support)
        if !capabilities.onDeviceAvailable, useOnlyOnDevice {
            useOnlyOnDevice = false
        }
        if !capabilities.ttsAvailable, autoPlayConfirmation {
            autoPlayConfirmation = false
        }

        let newContent = makeContent(capabilities: capabilities, permissions: permissions)

        // Update state while preserving 'saving' or 'error' context if necessary
        switch state {
        case .loading, .content:
            state = .content(newContent)
        case .saving:
            state = .saving(newContent)
        case let .error(err, _):
            state = .error(err, newContent)
        }
    }

    private func makeContent(
        capabilities: SpeechCapabilities,
        permissions: (PermissionStatus, PermissionStatus)
    ) -> Content {
        let hasPermissions = permissions.0.isAuthorized && permissions.1.isAuthorized
        let isSupported = capabilities.isCriticalValid

        let shouldAllowSave = isSupported && (hasPermissions || mode == .settings)

        return Content(
            capabilities: capabilities,
            missingPermissions: !hasPermissions,
            canSave: shouldAllowSave,
            warningMessage: isSupported ? nil : "settings_errorDescription_speech"
        )
    }

    // MARK: - Actions

    func buildConfiguration() -> SpeechConfiguration? {
        guard state.content.canSave else { return nil }

        return SpeechConfiguration(
            language: selectedLocale.identifier,
            useOnlyOnDevice: useOnlyOnDevice,
            autoPlayConfirmation: autoPlayConfirmation
        )
    }

    func clearDrafts() {
        draftService.clearDraft()
    }

    func save() {
        guard state.content.canSave else { return }

        let configToSave = SpeechConfiguration(
            language: selectedLocale.identifier,
            useOnlyOnDevice: useOnlyOnDevice,
            autoPlayConfirmation: autoPlayConfirmation
        )

        state = .saving(state.content)

        do {
            try configManager.saveSpeechConfiguration(configToSave)
            draftService.clearDraft()
            state = .content(state.content)
        } catch {
            let appError = (error as? AppError) ?? .configurationFailed(error.localizedDescription)
            state = .error(appError, state.content)
        }
    }

    func dismissError() {
        if case .error = state {
            state = .content(state.content)
        }
    }

    /// Used for Previews/Tests to stop automatic state updates
    func stopPipelines() {
        cancellables.removeAll()
    }
}
