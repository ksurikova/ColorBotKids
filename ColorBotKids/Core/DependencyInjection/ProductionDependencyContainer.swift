//
//  ProductionDependencyContainer.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//

import Foundation
import PencilKit
import SwiftUI

@MainActor
final class ProductionDependencyContainer: AppDependencyContainer {
    // MARK: - Selected Service Types

    // Define types here to ensure consistency between initialization and availability checks
    private typealias SpeechService = LiveSpeechRecognitionService

    let mainServicesManager: MainServicesManager
    let permissionManager: PermissionManager
    let sessionManager: SessionManager
    let imageToolingManager: ImageToolingManager
    let contentViewModel: ContentViewModel
    let router: AppRouter
    let speechConfigurationDraftService: SpeechConfigurationDraftService

    init() {
        // 1. Core Service Types
        let speechServiceType = SpeechService.self
        let ttsServiceType = AVTextToSpeechService.self
        let imageFactory = LiveImageGenerationServiceFactory()

        // 2. Tooling Services
        let drawService = DefaultDrawService()
        let saveService = DefaultImageSaveService()
        let settingsService = DefaultSettingsService()

        imageToolingManager = ImageToolingManager(
            drawService: drawService,
            saveService: saveService
        )

        // 3. Configuration & State
        let configStorage = CommonConfigurationStorage()
        let stateStorage = UserDefaultsStateStorage()
        let stateRestoration = DefaultStateRestorationService()
        let permissionService = DefaultPermissionService()

        // 4. Managers
        let servicesFactory = MainServiceFactory(
            imageGenerationServiceFactory: imageFactory
        )

        // Dependency Injection for ConfigurationManager
        let configManager = ConfigurationManager(
            storage: configStorage,
            resolver: SpeechCapabilityResolver(
                speechService: speechServiceType, ttsService: ttsServiceType
            )
        )

        permissionManager = PermissionManager(service: permissionService)
        sessionManager = SessionManager(
            stateStorage: stateStorage,
            restorationService: stateRestoration
        )

        mainServicesManager = MainServicesManager(
            configurationManager: configManager,
            servicesFactory: servicesFactory
        )

        speechConfigurationDraftService = LocalSpeechDraftService()

        // 5. Build View Models & Router
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
        if !SpeechService.canRunApp() {
            return SpeechService
                .unavailabilityMessage() ?? String(localized: "common_error_appCannotStart")
        }
        return nil
    }
}
