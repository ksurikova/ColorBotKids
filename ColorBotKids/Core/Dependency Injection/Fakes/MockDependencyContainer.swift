//
//  MockDependencyContainer.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//

import Foundation
import PencilKit
import SwiftUI

final class MockDependencyContainer: AppDependencies {
    let configurationManager: ConfigurationManaging
    let mainServicesManager: MainServicesManaging
    let permissionManager: PermissionManaging
    let sessionManager: SessionManaging
    let imageToolingManager: ImageToolingManaging
    let speechCapabilityResolver: SpeechCapabilityResolving
    let speechConfigurationDraftService: SpeechConfigurationDraftService
    let aiConfigurationDraftService: AIConfigurationDraftService
    let settingsService: SettingsService

    init(
        configuration: AppConfiguration? = nil,
        permissionStatuses: [String: PermissionStatus]? = nil
    ) {
        imageToolingManager = Self.makeToolingManager()
        permissionManager = Self.makePermissionManager(with: permissionStatuses)
        sessionManager = Self.makeSessionManager()
        speechCapabilityResolver = SpeechCapabilityResolver(
            speechService: MockSpeechRecognitionService.self,
            ttsService: MockTextToSpeechService.self
        )
        configurationManager = Self.makeConfigurationManager(
            with: configuration,
            resolver: speechCapabilityResolver
        )
        mainServicesManager = Self.makeMainServicesManager(
            configurationManager: configurationManager
        )
        speechConfigurationDraftService = MockSpeechConfigurationDraftService()
        aiConfigurationDraftService = MockAIConfigurationDraftService()
        settingsService = MockSettingsService()
    }

    // MARK: - Factory Methods

    private static func makeToolingManager() -> ImageToolingManager {
        let drawService = MockDrawService()
        let saveService = MockImageSaveService()

        return ImageToolingManager(
            drawService: drawService,
            saveService: saveService
        )
    }

    private static func makePermissionManager(with statuses: [String: PermissionStatus]?)
        -> PermissionManager {
        let defaultStatuses: [String: PermissionStatus] = [
            "microphone": .authorized,
            "speechRecognition": .authorized,
            "photoLibrary": .authorized,
        ]

        let permissionService = MockPermissionService(
            permissionStatuses: statuses ?? defaultStatuses
        )

        let manager = PermissionManager(service: permissionService)
        // Ensure the manager reflects the mock service state immediately
        manager.checkAll()
        return manager
    }

    private static func makeSessionManager() -> SessionManaging {
        let stateStorage = MockStateStorage()
        let stateRestoration = MockStateRestorationService()

        return SessionManager(
            stateStorage: stateStorage,
            restorationService: stateRestoration
        )
    }

    private static func makeConfigurationManager(
        with configuration: AppConfiguration?,
        resolver: SpeechCapabilityResolving
    ) -> ConfigurationManaging {
        // Default to a valid working configuration if none provided (common for previews)
        let defaultConfig = AppConfiguration(
            aiConfig: AIConfiguration(provider: .mock, apiKey: "mock-key"),
            speechConfig: SpeechConfiguration(
                language: "en-US",
                useOnlyOnDevice: false,
                autoPlayConfirmation: true
            )
        )

        let configStorage = MockConfigurationStorage(
            shouldLoadConfig: true,
            currentConfiguration: configuration ?? defaultConfig
        )

        return ConfigurationManager(
            storage: configStorage,
            resolver: resolver
        )
    }

    private static func makeMainServicesManager(
        configurationManager: ConfigurationManaging
    ) -> MainServicesManaging {
        let imageFactory = ForcedMockImageGenerationServiceFactory()

        let servicesFactory = MainServiceFactory(
            imageGenerationServiceFactory: imageFactory
        )

        return MainServicesManager(
            configurationManager: configurationManager,
            servicesFactory: servicesFactory
        )
    }

    static func systemUnavailabilityReason() -> String? {
        nil
    }
}
