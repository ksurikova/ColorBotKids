//
//  StubDependencyContainer.swift
//  ColorBotKids
//
//  Created by GitHub Copilot on 06.05.2026.
//

import Foundation

final class StubDependencyContainer: AppDependencies {
    let configurationManager: ConfigurationManaging
    let mainServicesManager: MainServicesManaging
    let permissionManager: PermissionManaging
    let sessionManager: SessionManaging
    let imageToolingManager: ImageToolingManaging
    let settingsService: SettingsService
    let speechConfigurationDraftService: SpeechConfigurationDraftService
    let aiConfigurationDraftService: AIConfigurationDraftService

    init(
        configurationManager: ConfigurationManaging = StubConfigurationManager(),
        mainServicesManager: MainServicesManaging = StubMainServicesManager(),
        permissionManager: PermissionManaging = StubPermissionManager(),
        sessionManager: SessionManaging = StubSessionManager(),
        imageToolingManager: ImageToolingManaging = StubImageToolingManager(),
        settingsService: SettingsService = MockSettingsService(),
        speechConfigurationDraftService: SpeechConfigurationDraftService =
            MockSpeechConfigurationDraftService(),
        aiConfigurationDraftService: AIConfigurationDraftService = MockAIConfigurationDraftService()
    ) {
        self.configurationManager = configurationManager
        self.mainServicesManager = mainServicesManager
        self.permissionManager = permissionManager
        self.sessionManager = sessionManager
        self.imageToolingManager = imageToolingManager
        self.settingsService = settingsService
        self.speechConfigurationDraftService = speechConfigurationDraftService
        self.aiConfigurationDraftService = aiConfigurationDraftService
    }
}
