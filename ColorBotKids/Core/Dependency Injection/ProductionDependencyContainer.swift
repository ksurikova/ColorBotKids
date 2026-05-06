//
//  ProductionDependencyContainer.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//

import Foundation
import PencilKit
import SwiftUI

final class ProductionDependencyContainer: AppDependencies {
    // MARK: - Selected Service Types

    // Define types here to ensure consistency between initialization and availability checks
    private typealias SpeechService = LiveSpeechRecognitionService
    private typealias TextToSpeechService = AVTextToSpeechService

    let configurationManager: ConfigurationManaging
    let mainServicesManager: MainServicesManaging
    let permissionManager: PermissionManaging
    let sessionManager: SessionManaging
    let imageToolingManager: ImageToolingManaging

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
        configurationManager = Self.makeConfigurationManager(resolver: speechCapabilityResolver)
        mainServicesManager = Self
            .makeMainServicesManager(configurationManager: configurationManager)
        speechConfigurationDraftService = LocalSpeechDraftService()
        aiConfigurationDraftService = LocalAIDraftService()
        settingsService = DefaultSettingsService()
    }

    // MARK: - Factory Methods

    private static func makeToolingManager() -> ImageToolingManaging {
        let drawService = DefaultDrawService()
        let saveService = DefaultImageSaveService()

        return ImageToolingManager(
            drawService: drawService,
            saveService: saveService
        )
    }

    private static func makePermissionManager() -> PermissionManaging {
        let permissionService = DefaultPermissionService()
        return PermissionManager(service: permissionService)
    }

    private static func makeSessionManager() -> SessionManaging {
        let stateStorage = UserDefaultsStateStorage()
        let stateRestoration = DefaultStateRestorationService()

        return SessionManager(
            stateStorage: stateStorage,
            restorationService: stateRestoration
        )
    }

    private static func makeConfigurationManager(resolver: SpeechCapabilityResolving)
        -> ConfigurationManaging {
        let configStorage = CommonConfigurationStorage()

        return ConfigurationManager(
            storage: configStorage,
            resolver: resolver
        )
    }

    private static func makeMainServicesManager(configurationManager: ConfigurationManaging)
        -> MainServicesManaging {
        let imageFactory = LiveImageGenerationServiceFactory()

        let servicesFactory = MainServiceFactory(
            imageGenerationServiceFactory: imageFactory
        )

        return MainServicesManager(
            configurationManager: configurationManager,
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
