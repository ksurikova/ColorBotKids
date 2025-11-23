//
//  AppStateManager.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//
import SwiftUI

enum AppRoute: Hashable {
    case loading
    case aiConfiguration
    case speechConfiguration
    case photoPermission
    case speechRecognition
}

final class AppModel: ObservableObject {
    @Published var currentConfiguration = AppConfiguration()
    @Published var microphoneStatus: PermissionStatus = .notDetermined
    @Published var speechRecognitionStatus: PermissionStatus = .notDetermined
    @Published var photoLibraryStatus: PermissionStatus = .notDetermined

    // TTS Feedback state
    @Published var showVolumeWarning = false
    @Published var ttsErrorMessage: String?

    private let storage: ConfigurationStorage
    private let speechServiceType: SpeechRecognitionService.Type

    var hasAllRequiredPermissions: Bool {
        Permissions.all
            .filter { $0.isRequired }
            .allSatisfy { permission in
                getPermissionStatus(permission).isAuthorized
            }
    }

    var hasSpeechPermissions: Bool {
        microphoneStatus.isAuthorized && speechRecognitionStatus.isAuthorized
    }

    var hasPhotoPermission: Bool {
        photoLibraryStatus.isAuthorized
    }

    var isFullyConfigured: Bool {
        currentConfiguration.isAIConfigured &&
            currentConfiguration.isSpeechConfigured &&
            hasAllRequiredPermissions
    }

    init(storage: ConfigurationStorage, speechServiceType: SpeechRecognitionService.Type) {
        self.storage = storage
        self.speechServiceType = speechServiceType
    }

    var autoPlayConfirmation: Bool {
        currentConfiguration.speechConfig?.autoPlayConfirmation ?? false
    }

    // MARK: - TTS Feedback Methods

    @MainActor
    func showVolumeLowWarning() {
        showVolumeWarning = true
        // Auto-dismiss after 5 seconds
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            showVolumeWarning = false
        }
    }

    @MainActor
    func showTTSError() {
        ttsErrorMessage = "Unable to play audio. Please check your audio settings."
        // Auto-dismiss after 4 seconds
        Task {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            ttsErrorMessage = nil
        }
    }

    func dismissVolumeWarning() {
        showVolumeWarning = false
    }

    func dismissTTSError() {
        ttsErrorMessage = nil
    }

    // MARK: - Configuration

    func loadConfiguration() {
        do {
            currentConfiguration = try storage.loadConfiguration()
            // Validate previously saved speech config
            if currentConfiguration.isSpeechConfigured {
                do {
                    _ = try createSpeechRecognitionSettings()
                } catch {
                    // Invalid configuration → reset to allow reconfiguration
                    currentConfiguration.speechConfig = nil
                }
            }
        } catch {
            currentConfiguration = AppConfiguration()
        }
    }

    // MARK: Save

    func updateSpeechConfiguration(_ config: SpeechConfiguration) throws {
        try storage.saveSpeechConfiguration(config)
        currentConfiguration.speechConfig = config

        // Create settings → validation happens here
        _ = try createSpeechRecognitionSettings()
    }

    // MARK: Conversion to runtime settings

    func createSpeechRecognitionSettings() throws -> SpeechRecognitionSettings {
        guard let config = currentConfiguration.speechConfig else {
            throw ConfigurationError.speechConfigurationMissing
        }

        let settings = SpeechRecognitionSettings(
            locale: Locale(identifier: config.language),
            requiresOnDevice: config.useOnlyOnDevice,
            shouldReportPartialResults: true
        )

        guard speechServiceType.canCreateWithCurrentSettings(settings) else {
            throw ConfigurationError.speechConfigurationInvalid
        }

        return settings
    }

    func createTTSSettings() throws -> TextToSpeechSettings {
        guard let config = currentConfiguration.speechConfig else {
            throw ConfigurationError.speechConfigurationMissing
        }

        let settings = TextToSpeechSettings(locale: Locale(identifier: config.language))

        return settings
    }

    // Single method that does both: save + update state
    func updateAIConfiguration(_ config: AIConfiguration) throws {
        try storage.saveAIConfiguration(config)
        currentConfiguration.aiConfig = config
    }

    // MARK: PERMISSIONS

    func updatePermissionStatus(_ permission: any PermissionDefinition, status: PermissionStatus) {
        switch permission.id {
        case Permissions.microphone.id:
            microphoneStatus = status
        case Permissions.speechRecognition.id:
            speechRecognitionStatus = status
        case Permissions.photoLibrary.id:
            photoLibraryStatus = status
        default:
            break
        }
    }

    func getPermissionStatus(_ permission: any PermissionDefinition) -> PermissionStatus {
        switch permission.id {
        case Permissions.microphone.id:
            return microphoneStatus
        case Permissions.speechRecognition.id:
            return speechRecognitionStatus
        case Permissions.photoLibrary.id:
            return photoLibraryStatus
        default:
            return .notDetermined
        }
    }

    @MainActor
    func refreshAllPermissions(using service: PermissionService) async {
        await withTaskGroup(of: (any PermissionDefinition, PermissionStatus).self) { group in
            for permission in Permissions.all {
                group.addTask {
                    (permission, service.checkPermission(for: permission))
                }
            }

            for await(permission, status) in group {
                print("For permission \(permission.id) status is \(status)")
                updatePermissionStatus(permission, status: status)
            }
        }
    }

    func reset() throws {
        try storage.deleteAll()
        currentConfiguration.reset()
    }
}

extension AppModel {
    var requiredRoute: AppRoute {
        if !currentConfiguration.isAIConfigured {
            return .aiConfiguration
        } else if !currentConfiguration.isSpeechConfigured {
            return .speechConfiguration
        } else if !hasSpeechPermissions {
            return .speechConfiguration // still speech config, since permission UI is there, but it
            // can be rare, only if user revokes permissions
        } else if photoLibraryStatus == .notDetermined {
            return .photoPermission
        } else {
            return .speechRecognition
        }
    }
}

extension AppModel {
    /// Returns the best locale to use based on saved config and available locales
    /// Priority: saved config → user's current locale → English → first available
    func selectInitialLocale(
        from supportedLocales: [Locale],
        savedConfig: SpeechConfiguration?
    ) -> Locale {
        // Validate we have locales to work with
        guard !supportedLocales.isEmpty else {
            assertionFailure("No supported locales available")
            return Locale(identifier: "en-US") // Fallback
        }

        if let savedLanguage = savedConfig?.language {
            let savedLocale = Locale(identifier: savedLanguage)
            if supportedLocales.contains(where: { $0.identifier == savedLocale.identifier }) {
                return savedLocale
            }
            print("⚠️ Saved locale '\(savedLanguage)' is no longer supported")
        }

        let currentLocale = Locale.current
        if supportedLocales.contains(where: { $0.identifier == currentLocale.identifier }) {
            return currentLocale
        }

        if let englishLocale = supportedLocales.first(where: {
            $0.identifier.hasPrefix("en")
        }) {
            return englishLocale
        }

        return supportedLocales[0]
    }
}

extension AppModel {
    static func mock(
        with configuration: AppConfiguration = AppConfiguration(),
        storage: ConfigurationStorage? = nil
    ) -> AppModel {
        let mockStorage = storage ?? MockConfigurationStorage(
            shouldLoadConfig: true,
            currentConfiguration: configuration
        )
        let mockSpeechType = MockSpeechRecognitionService.self
        let model = AppModel(storage: mockStorage, speechServiceType: mockSpeechType)
        model.currentConfiguration = configuration
        return model
    }

    // Convenience for common cases
    static func mockUnconfigured() -> AppModel {
        mock(with: AppConfiguration())
    }

    static func mockWithAI(
        provider: ImageProvider = .mock, apiKey: String = "test-key"
    ) -> AppModel {
        mock(with: AppConfiguration(
            aiConfig: AIConfiguration(provider: provider, apiKey: apiKey),
            speechConfig: nil
        ))
    }

    static func mockFullyConfigured() -> AppModel {
        mock(with: AppConfiguration(
            aiConfig: AIConfiguration(provider: .mock, apiKey: "test-key"),
            speechConfig: SpeechConfiguration(
                language: "en",
                useOnlyOnDevice: false,
                autoPlayConfirmation: true
            )
        ))
    }
}
