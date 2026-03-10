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
    enum ConfigurationMode {
        case onboarding // Strict: Must have permissions to be "valid"
        case settings // Relaxed: Can be valid even without permissions
    }

    // MARK: - Dependencies

    private let configManager: ConfigurationManager
    private let draftService: SpeechConfigurationDraftService
    let permissionManager: PermissionManager
    private let mode: ConfigurationMode

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Input State

    @Published var selectedLocale: Locale
    @Published var useOnlyOnDevice: Bool = false
    @Published var autoPlayConfirmation: Bool = false

    // MARK: - Output State

    @Published private(set) var capabilities: SpeechCapabilities?
    @Published private(set) var isSaving: Bool = false
    @Published private(set) var error: AppError?
    @Published private(set) var warningMessage: String?
    @Published private(set) var missingPermissions: Bool = true
    @Published private(set) var canSave: Bool = false

    // MARK: - Initialization

    init(
        configManager: ConfigurationManager,
        permissionManager: PermissionManager,
        draftService: SpeechConfigurationDraftService = LocalSpeechDraftService(),
        mode: ConfigurationMode = .onboarding
    ) {
        self.configManager = configManager
        self.permissionManager = permissionManager
        self.draftService = draftService
        self.mode = mode

        // Resolve Initial State (Priority: Draft > Live > Default)
        let draft = draftService.loadDraft()
        let live = configManager.configuration.speechConfig
        let defaultLocale = configManager.getInitialLocale()

        // Initialize properties
        if let config = draft ?? live {
            selectedLocale = Locale(identifier: config.language)
            useOnlyOnDevice = config.useOnlyOnDevice
            autoPlayConfirmation = config.autoPlayConfirmation
        } else {
            selectedLocale = defaultLocale
            useOnlyOnDevice = false
            autoPlayConfirmation = false
        }

        setupPipelines()
    }

    // MARK: - Pipelines

    private func setupPipelines() {
        setupLocalePipeline()
        setupPermissionPipeline()
        setupValidationPipeline()
        // Only enable Draft Saving in Settings mode
        if mode == .settings {
            setupDraftAutoSavePipeline()
        }
    }

    private func setupLocalePipeline() {
        $selectedLocale
            .map { [configManager] locale in
                configManager.resolveCapabilities(for: locale)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] caps in
                guard let self = self else { return }
                self.capabilities = caps
                // Force toggle consistency based on capabilities
                if !caps.onDeviceAvailable { self.useOnlyOnDevice = false }
                if !caps.ttsAvailable { self.autoPlayConfirmation = false }

                self.warningMessage = caps
                    .isCriticalValid ? nil : String(localized: "speech_warning_notSupported")
            }
            .store(in: &cancellables)
    }

    private func setupPermissionPipeline() {
        Publishers.CombineLatest(
            permissionManager.microphone,
            permissionManager.speechRecognition
        )
        .map { mic, speech in
            !(mic.isAuthorized && speech.isAuthorized)
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$missingPermissions)
    }

    private func setupValidationPipeline() {
        // Can save if: Capabilities are valid AND permissions are granted (if strictly required)
        Publishers.CombineLatest($capabilities, $missingPermissions)
            .map { [mode] caps, isMissing in
                let isCriticalValid = caps?.isCriticalValid ?? false
                switch mode {
                case .onboarding:
                    return isCriticalValid && !isMissing
                case .settings:
                    // In Settings, we allow saving valid config even if permissions are missing
                    // (User might fix permissions later)
                    return isCriticalValid
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$canSave)
    }

    private func setupDraftAutoSavePipeline() {
        // Aggregate state changes and save to draft service
        Publishers.CombineLatest3($selectedLocale, $useOnlyOnDevice, $autoPlayConfirmation)
            .dropFirst() // Skip initial load
            .sink { [weak self] locale, device, autoPlay in
                guard let self = self else { return }

                let config = SpeechConfiguration(
                    language: locale.identifier,
                    useOnlyOnDevice: device,
                    autoPlayConfirmation: autoPlay
                )
                self.draftService.saveDraft(config)
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API for Parents

    /// Returns the configuration object if valid, otherwise nil.
    func buildConfiguration() -> SpeechConfiguration? {
        // Validation logic matches setupValidationPipeline
        let isCriticalValid = capabilities?.isCriticalValid ?? false

        switch mode {
        case .onboarding:
            guard isCriticalValid, !missingPermissions else { return nil }
        case .settings:
            guard isCriticalValid else { return nil }
        }

        return SpeechConfiguration(
            language: selectedLocale.identifier,
            useOnlyOnDevice: useOnlyOnDevice,
            autoPlayConfirmation: autoPlayConfirmation
        )
    }

    // MARK: - Actions

    func save() {
        guard canSave else { return }

        // Construct the config
        let configToSave = SpeechConfiguration(
            language: selectedLocale.identifier,
            useOnlyOnDevice: useOnlyOnDevice,
            autoPlayConfirmation: autoPlayConfirmation
        )

        isSaving = true
        error = nil
        do {
            // Save to Permanent Storage
            try configManager.saveSpeechConfiguration(configToSave)
            // Clear Temporary Draft on success
            draftService.clearDraft()
        } catch {
            self
                .error = (error as? AppError) ??
                .configurationFailed(error.localizedDescription)
        }
        isSaving = false
    }

    // Added for SettingsViewModel compatibility
    func clearDrafts() {
        draftService.clearDraft()
    }

    func dismissError() {
        error = nil
    }

    var supportedLocales: [Locale] {
        configManager.getCapableLocales()
    }
}
