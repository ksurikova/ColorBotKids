//
//  ViewModelBuilder.swift
//  ColorBotKids
//
//  Created by ksurikova on 24.04.2026.
//

import SwiftUI

@MainActor
protocol ViewModelBuilder {
    func makeContentViewModel() -> ContentViewModel
    func makeAiConfigurationViewModel() -> AIConfigurationViewModel
    func makePhotoLibraryViewModel() -> PhotoLibraryViewModel
    func makeSpeechConfigurationViewModel(mode: SpeechConfigurationViewModel.ConfigurationMode)
        -> SpeechConfigurationViewModel
    func makeSpeechViewModel() -> SpeechRecognitionViewModel
    func makeEditorViewModel() -> ImageEditorViewModel?
    func makeSettingsViewModel() -> SettingsViewModel
}

@MainActor
final class DefaultViewModelBuilder: ViewModelBuilder {
    let dependencies: AppDependencies
    // Cache the Speech VM here so it doesn't reset when navigating
    private var cachedSpeechVM: SpeechRecognitionViewModel?

    func makeContentViewModel() -> ContentViewModel {
        ContentViewModel(configurationManager: dependencies.configurationManager,
                         permissionManager: dependencies.permissionManager,
                         sessionManager: dependencies.sessionManager)
    }

    func makeAiConfigurationViewModel() -> AIConfigurationViewModel {
        AIConfigurationViewModel(
            configManager: dependencies.configurationManager,
            draftService: dependencies.aiConfigurationDraftService
        )
    }

    func makePhotoLibraryViewModel() -> PhotoLibraryViewModel {
        PhotoLibraryViewModel(manager: dependencies.permissionManager)
    }

    func makeSpeechConfigurationViewModel(mode: SpeechConfigurationViewModel
        .ConfigurationMode) -> SpeechConfigurationViewModel {
        SpeechConfigurationViewModel(
            configManager: dependencies.configurationManager,
            permissionManager: dependencies.permissionManager,
            draftService: dependencies.speechConfigurationDraftService,
            mode: mode
        )
    }

    func makeSpeechViewModel() -> SpeechRecognitionViewModel {
        if let cached = cachedSpeechVM { return cached }
        let vm = SpeechRecognitionViewModel(
            servicesManager: dependencies.mainServicesManager,
            sessionManager: dependencies.sessionManager
        )
        cachedSpeechVM = vm
        return vm
    }

    func makeEditorViewModel() -> ImageEditorViewModel? {
        guard dependencies.sessionManager.currentSession != nil else { return nil }
        return ImageEditorViewModel(
            sessionManager: dependencies.sessionManager,
            toolingManager: dependencies.imageToolingManager,
            permissionManager: dependencies.permissionManager,
            settingsService: dependencies.settingsService
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        let aiVM = makeAiConfigurationViewModel()
        let speechVM = makeSpeechConfigurationViewModel(mode: .settings)
        let photoVM = makePhotoLibraryViewModel()

        return SettingsViewModel(
            aiViewModel: aiVM,
            speechViewModel: speechVM,
            photoViewModel: photoVM,
            configurationManager: dependencies.configurationManager
        )
    }

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }
}
