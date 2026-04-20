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
final class ProductionDependencyContainer: AppDependencyContainer, AppDependencies {
    // MARK: - Selected Service Types

    // Define types here to ensure consistency between initialization and availability checks
    private typealias SpeechService = LiveSpeechRecognitionService
    private typealias TextToSpeechService = AVTextToSpeechService

    let mainServicesManager: MainServicesManager
    let permissionManager: PermissionManager
    let sessionManager: SessionManager
    let imageToolingManager: ImageToolingManager
    lazy var contentViewModel: ContentViewModel = .init(dependencies: self)
    lazy var router: AppRouter = .init(dependencies: self)
    let speechCapabilityResolver: SpeechCapabilityResolving
    let speechConfigurationDraftService: SpeechConfigurationDraftService
    let aiConfigurationDraftService: AIConfigurationDraftService
    let settingsService: SettingsService

    init() {
        imageToolingManager = Self.makeToolingManager()
        permissionManager = Self.makePermissionManager()
        sessionManager = Self.makeSessionManager()
        speechCapabilityResolver = SpeechCapabilityResolver(
            speechService: SpeechService.self,
            ttsService: TextToSpeechService.self
        )
        mainServicesManager = Self.makeMainServicesManager(resolver: speechCapabilityResolver)
        speechConfigurationDraftService = LocalSpeechDraftService()
        aiConfigurationDraftService = LocalAIDraftService()
        settingsService = DefaultSettingsService()
    }

    // MARK: - Factory Methods

    private static func makeToolingManager() -> ImageToolingManager {
        let drawService = DefaultDrawService()
        let saveService = DefaultImageSaveService()

        return ImageToolingManager(
            drawService: drawService,
            saveService: saveService
        )
    }

    private static func makePermissionManager() -> PermissionManager {
        let permissionService = DefaultPermissionService()
        return PermissionManager(service: permissionService)
    }

    private static func makeSessionManager() -> SessionManager {
        let stateStorage = UserDefaultsStateStorage()
        let stateRestoration = DefaultStateRestorationService()

        return SessionManager(
            stateStorage: stateStorage,
            restorationService: stateRestoration
        )
    }

    private static func makeMainServicesManager(resolver: SpeechCapabilityResolving)
        -> MainServicesManager {
        let imageFactory = LiveImageGenerationServiceFactory()

        let configStorage = CommonConfigurationStorage()

        let servicesFactory = MainServiceFactory(
            imageGenerationServiceFactory: imageFactory
        )

        let configManager = ConfigurationManager(
            storage: configStorage,
            resolver: resolver
        )

        return MainServicesManager(
            configurationManager: configManager,
            servicesFactory: servicesFactory
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
