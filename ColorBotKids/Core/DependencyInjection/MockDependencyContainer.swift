//
//  MockDependencyContainer.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//

import Foundation
import PencilKit
import SwiftUI

// A private factory to improve mock reliability by forcing mock service regardless of config
private struct ForcedMockImageGenerationServiceFactory: ImageGenerationServiceFactory {
    func make(for config: AIConfiguration) -> ImageGenerationService {
        // Always return Mock service, even if config is for OpenAI/StabilityAI
        MockImageGenerationService(config: config.toImageGenerationConfig())
    }
}

@MainActor
final class MockDependencyContainer: AppDependencyContainer {
    let mainServicesManager: MainServicesManager
    let permissionManager: PermissionManager
    let sessionManager: SessionManager
    let imageToolingManager: ImageToolingManager
    let contentViewModel: ContentViewModel
    let router: AppRouter
    let speechConfigurationDraftService: SpeechConfigurationDraftService

    // Add Configuration and Permission overrides to make previews effortless
    init(
        configuration: AppConfiguration? = nil,
        permissionStatuses: [String: PermissionStatus]? = nil
    ) {
        // Core Service Types (Mocks)
        let speechServiceType = MockSpeechRecognitionService.self
        let ttsServiceType = MockTextToSpeechService.self
        let imageFactory = ForcedMockImageGenerationServiceFactory()

        // Tooling Services (Mocks)
        let drawService = MockDrawService()
        let saveService = MockImageSaveService()
        let settingsService = MockSettingsService()

        imageToolingManager = ImageToolingManager(
            drawService: drawService,
            saveService: saveService
        )

        // Configuration & State (Mocks)
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
        let stateStorage = MockStateStorage()
        let stateRestoration = MockStateRestorationService()

        // Default to authorized permissions if none provided (common for previews)
        let defaultStatuses: [String: PermissionStatus] = [
            "microphone": .authorized,
            "speechRecognition": .authorized,
            "photoLibrary": .authorized,
        ]

        let permissionService = MockPermissionService(
            permissionStatuses: permissionStatuses ?? defaultStatuses
        )

        speechConfigurationDraftService = MockSpeechConfigurationDraftService()

        // Managers
        let servicesFactory = MainServiceFactory(
            imageGenerationServiceFactory: imageFactory
        )

        let configManager = ConfigurationManager(
            storage: configStorage,
            resolver: SpeechCapabilityResolver(
                speechService: speechServiceType, ttsService: ttsServiceType
            )
        )

        permissionManager = PermissionManager(service: permissionService)
        // Ensure the manager reflects the mock service state immediately
        permissionManager.checkAll()

        sessionManager = SessionManager(
            stateStorage: stateStorage,
            restorationService: stateRestoration
        )

        mainServicesManager = MainServicesManager(
            configurationManager: configManager,
            servicesFactory: servicesFactory
        )

        // Build View Models & Router
        contentViewModel = ContentViewModel(
            mainServicesManager: mainServicesManager,
            permissionManager: permissionManager,
            sessionManager: sessionManager,
            imageToolingManager: imageToolingManager
        )

        router = AppRouter(
            mainServicesManager: mainServicesManager,
            permissionManager: permissionManager,
            sessionManager: sessionManager,
            imageToolingManager: imageToolingManager,
            settingsService: settingsService,
            speechConfigurationDraftService: speechConfigurationDraftService
        )
    }

    static func systemUnavailabilityReason() -> String? {
        nil
    }
}
