//
//  AppDependencies.swift
//  ColorBotKids
//
//  Created by ksurikova on 29.04.2026.
//

protocol AppDependencies {
    var configurationManager: ConfigurationManager { get }
    var mainServicesManager: MainServicesManager { get }
    var permissionManager: PermissionManager { get }
    var sessionManager: SessionManager { get }
    var imageToolingManager: ImageToolingManager { get }
    var settingsService: SettingsService { get }
    var speechConfigurationDraftService: SpeechConfigurationDraftService { get }
    var aiConfigurationDraftService: AIConfigurationDraftService { get }
}
