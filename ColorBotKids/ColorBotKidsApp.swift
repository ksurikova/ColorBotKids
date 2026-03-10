//
//  ColorBotKidsApp.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//

import SwiftUI

struct AppDependencies {
    let mainServicesManager: MainServicesManager
    let permissionManager: PermissionManager
    let sessionManager: SessionManager
    let imageToolingManager: ImageToolingManager
    let contentViewModel: ContentViewModel
    let router: AppRouter
}

enum AppBootstrapState {
    case supported(AppDependencies)
    case unsupported(String)
}

// In App initialization
@main
struct ColorBotKidsApp: App {
    private let bootstrapState: AppBootstrapState

    init() {
        let speechServiceType = LiveSpeechRecognitionService.self

        // Check critical service immediately
        guard speechServiceType.canRunApp() else {
            bootstrapState = .unsupported(
                speechServiceType
                    .unavailabilityMessage() ?? String(localized: "common_error_appCannotStart")
            )
            return
        }

        let ttsServiceType = AVTextToSpeechService.self
        let imageFactory = LiveImageGenerationServiceFactory()

        // Tooling Services
        let drawService = DefaultDrawService()
        let saveService = DefaultImageSaveService()
        let settingsService = DefaultSettingsService()

        let imageToolingManager = ImageToolingManager(
            drawService: drawService,
            saveService: saveService
        )

        let configStorage = CommonConfigurationStorage()
        let stateStorage = UserDefaultsStateStorage()
        let stateRestoration = DefaultStateRestorationService()
        let permissionService = DefaultPermissionService()

        // Create service factory
        let servicesFactory = MainServiceFactory(
            imageGenerationServiceFactory: imageFactory
        )

        let configManager = ConfigurationManager(
            storage: configStorage,
            resolver: SpeechCapabilityResolver(
                speechService: speechServiceType, ttsService: ttsServiceType
            )
        )

        let permissionManager = PermissionManager(service: permissionService)
        let sessionManager = SessionManager(
            stateStorage: stateStorage,
            restorationService: stateRestoration
        )

        let servicesManager = MainServicesManager(
            configurationManager: configManager,
            servicesFactory: servicesFactory
        )

        let contentViewModel = ContentViewModel(
            mainServicesManager: servicesManager,
            permissionManager: permissionManager,
            sessionManager: sessionManager,
            imageToolingManager: imageToolingManager
        )

        let router = AppRouter(
            mainServicesManager: servicesManager,
            permissionManager: permissionManager,
            sessionManager: sessionManager,
            imageToolingManager: imageToolingManager,
            settingsService: settingsService
        )

        let dependencies = AppDependencies(
            mainServicesManager: servicesManager,
            permissionManager: permissionManager,
            sessionManager: sessionManager,
            imageToolingManager: imageToolingManager,
            contentViewModel: contentViewModel,
            router: router
        )
        bootstrapState = .supported(dependencies)
    }

    var body: some Scene {
        WindowGroup {
            switch bootstrapState {
            case let .supported(dependencies):
                ContentView(viewModel: dependencies.contentViewModel, router: dependencies.router)
            // TODO: add reason to my view
            case .unsupported:
                UnsupportedView()
            }
        }
    }
}
