//
//  MockDependencyContainer.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//

import Foundation
import PencilKit
import SwiftUI

@MainActor
final class MockDependencyContainer: AppDependencyContainer {
    let mainServicesManager: MainServicesManager
    let permissionManager: PermissionManager
    let sessionManager: SessionManager
    let imageToolingManager: ImageToolingManager
    let contentViewModel: ContentViewModel
    let router: AppRouter
    let speechConfigurationDraftService: SpeechConfigurationDraftService
    let aiConfigurationDraftService: AIConfigurationDraftService

    init(
        configuration: AppConfiguration? = nil,
        permissionStatuses: [String: PermissionStatus]? = nil
    ) {
        imageToolingManager = Self.makeToolingManager()
        permissionManager = Self.makePermissionManager(with: permissionStatuses)
        sessionManager = Self.makeSessionManager()
        mainServicesManager = Self.makeMainServicesManager(with: configuration)
        speechConfigurationDraftService = MockSpeechConfigurationDraftService()
        aiConfigurationDraftService = MockAIConfigurationDraftService()

        // Build View Models & Router
        contentViewModel = ContentViewModel(
            mainServicesManager: mainServicesManager,
            permissionManager: permissionManager,
            sessionManager: sessionManager,
            imageToolingManager: imageToolingManager
        )

        let settingsService = MockSettingsService()
        router = AppRouter(
            mainServicesManager: mainServicesManager,
            permissionManager: permissionManager,
            sessionManager: sessionManager,
            imageToolingManager: imageToolingManager,
            settingsService: settingsService,
            speechConfigurationDraftService: speechConfigurationDraftService,
            aiConfigurationDraftService: aiConfigurationDraftService
        )
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

    private static func makeSessionManager() -> SessionManager {
        let stateStorage = MockStateStorage()
        let stateRestoration = MockStateRestorationService()

        return SessionManager(
            stateStorage: stateStorage,
            restorationService: stateRestoration
        )
    }

    private static func makeMainServicesManager(with configuration: AppConfiguration?)
        -> MainServicesManager {
        let speechServiceType = MockSpeechRecognitionService.self
        let ttsServiceType = MockTextToSpeechService.self
        let imageFactory = ForcedMockImageGenerationServiceFactory()

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

        let servicesFactory = MainServiceFactory(
            imageGenerationServiceFactory: imageFactory
        )

        let configManager = ConfigurationManager(
            storage: configStorage,
            resolver: SpeechCapabilityResolver(
                speechService: speechServiceType, ttsService: ttsServiceType
            )
        )

        return MainServicesManager(
            configurationManager: configManager,
            servicesFactory: servicesFactory
        )
    }

    static func systemUnavailabilityReason() -> String? {
        nil
    }
}
