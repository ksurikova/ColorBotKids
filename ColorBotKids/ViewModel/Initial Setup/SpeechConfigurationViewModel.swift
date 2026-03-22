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
        var warningMessage: String?
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

    // MARK: - Input State

    @Published var selectedLocale: Locale
    @Published var useOnlyOnDevice: Bool = false
    @Published var autoPlayConfirmation: Bool = false

    // MARK: - Output State

    @Published var state: ScreenState = .loading

    var supportedLocales: [Locale] {
        configManager.getCapableLocales()
    }

    // Compatibility properties
    var canSave: Bool { state.content.canSave }
    var error: AppError? { state.error }

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
        let capabilitiesPublisher = $selectedLocale
            .map { [configManager] locale in
                configManager.resolveCapabilities(for: locale)
            }

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

        // Only enable Draft Saving in Settings mode
        if mode == .settings {
            setupDraftAutoSavePipeline()
        }
    }

    private func handleStateUpdate(
        capabilities: SpeechCapabilities,
        permissions: (PermissionStatus, PermissionStatus)
    ) {
        // 1. Handle Side Effects on Input (Toggles)
        if !capabilities.onDeviceAvailable, useOnlyOnDevice {
            useOnlyOnDevice = false
        }
        if !capabilities.ttsAvailable, autoPlayConfirmation {
            autoPlayConfirmation = false
        }

        // 2. Prepare Data
        let newContent = makeContent(capabilities: capabilities, permissions: permissions)

        // 3. Update State (Preserving current mode if saving/error)
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
        let missingPermissions = !(permissions.0.isAuthorized && permissions.1.isAuthorized)
        let isCriticalValid = capabilities.isCriticalValid

        // Unified Logic: Always check permissions
        let canSave = isCriticalValid && !missingPermissions

        let warning = isCriticalValid ? nil :
            String(localized: "speech_warning_notSupported")

        return Content(
            capabilities: capabilities,
            missingPermissions: missingPermissions,
            canSave: canSave,
            warningMessage: warning
        )
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

    // MARK: - Debug only

    #if DEBUG
        func stopPipelines() {
            cancellables.removeAll()
        }
    #endif

    // MARK: - Public API for Parents

    // Returns the configuration object if valid, otherwise nil.
    func buildConfiguration() -> SpeechConfiguration? {
        // Validation logic matches setupValidationPipeline
        let isCriticalValid = state.content.capabilities?.isCriticalValid ?? false

        // Unified validation: Permissions are required
        guard isCriticalValid, !state.content.missingPermissions else { return nil }

        return SpeechConfiguration(
            language: selectedLocale.identifier,
            useOnlyOnDevice: useOnlyOnDevice,
            autoPlayConfirmation: autoPlayConfirmation
        )
    }

    func save() {
        guard state.content.canSave else { return }

        // Construct the config
        let configToSave = SpeechConfiguration(
            language: selectedLocale.identifier,
            useOnlyOnDevice: useOnlyOnDevice,
            autoPlayConfirmation: autoPlayConfirmation
        )

        state = .saving(state.content)
        do {
            // Save to Permanent Storage
            try configManager.saveSpeechConfiguration(configToSave)
            // Clear Temporary Draft on success
            draftService.clearDraft()
            state = .content(state.content)
        } catch {
            state = .error(
                (error as? AppError) ?? .configurationFailed(error.localizedDescription),
                state.content
            )
        }
    }

    // Added for SettingsViewModel compatibility
    func clearDrafts() {
        draftService.clearDraft()
    }

    func dismissError() {
        if case .error = state {
            state = .content(state.content)
        }
    }
}
