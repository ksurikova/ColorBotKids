//
//  PreviewMocks.swift
//  ColorBotKids
//
//  Created by ksurikova on 06.05.2026.
//

import Combine
import SwiftUI

enum PreviewMocks {
    static var mockContainer: MockDependencyContainer {
        MockDependencyContainer()
    }

    @MainActor
    static var builder: DefaultViewModelBuilder {
        DefaultViewModelBuilder(dependencies: mockContainer)
    }

    @MainActor
    static var router: AppRouter {
        let container = mockContainer
        return AppRouter(
            builder: builder,
            configurationManager: container.configurationManager,
            permissionManager: container.permissionManager,
            sessionManager: container.sessionManager
        )
    }

    // MARK: - View Models

    @MainActor
    static var contentViewModel: ContentViewModel {
        builder.makeContentViewModel()
    }

    @MainActor
    static var aiConfigurationViewModel: AIConfigurationViewModel {
        builder.makeAiConfigurationViewModel()
    }

    @MainActor
    static var speechRecognitionViewModel: SpeechRecognitionViewModel {
        builder.makeSpeechViewModel()
    }

    @MainActor
    static var photoLibraryViewModel: PhotoLibraryViewModel {
        builder.makePhotoLibraryViewModel()
    }

    @MainActor
    static var settingsViewModel: SettingsViewModel {
        builder.makeSettingsViewModel()
    }
}
