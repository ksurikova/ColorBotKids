//
//  AppDependencies.swift
//  ColorBotKids
//
//  Created by ksurikova on 29.04.2026.
//

protocol AppDependencies {
    var configurationManager: ConfigurationManaging { get }
    var mainServicesManager: MainServicesManaging { get }
    var permissionManager: PermissionManaging { get }
    var sessionManager: SessionManaging { get }
    var imageToolingManager: ImageToolingManaging { get }
    var settingsService: SettingsService { get }
    var speechConfigurationDraftService: SpeechConfigurationDraftService { get }
    var aiConfigurationDraftService: AIConfigurationDraftService { get }
}
