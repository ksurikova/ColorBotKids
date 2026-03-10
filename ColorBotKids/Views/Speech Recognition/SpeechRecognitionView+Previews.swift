//
//  SpeechRecognitionView+Previews.swift
//  ColorBotKids
//
//  Created by ksurikova on 10.03.2026.
//

import Combine
import SwiftUI

// This helper sets up the entire dependency graph with mocks for previews.
@MainActor
private struct PreviewHelper {
    let viewModel: SpeechRecognitionViewModel
    let configManager: ConfigurationManager
    let permissionManager: PermissionManager
    let servicesManager: MainServicesManager // Keep reference to prevent dealloc if weak refs exist
    let sessionManager: SessionManager // Keep reference

    init(state: MainActionState) {
        // 1. Storage & Configuration
        let mockConfig = AppConfiguration(
            aiConfig: AIConfiguration(provider: .mock, apiKey: "test-key"),
            speechConfig: SpeechConfiguration(
                language: "en-US",
                useOnlyOnDevice: false,
                autoPlayConfirmation: true
            )
        )

        let storage = MockConfigurationStorage(
            shouldLoadConfig: true,
            currentConfiguration: mockConfig
        )

        // 2. Resolvers & Services
        let resolver = SpeechCapabilityResolver(
            speechService: MockSpeechRecognitionService.self,
            ttsService: MockTextToSpeechService.self
        )

        // 3. Managers
        configManager = ConfigurationManager(storage: storage, resolver: resolver)
        // Critical: Load the configuration into memory so services can be created
        configManager.load()

        // Factory that returns MockImageGenerationService because config provider is .mock
        let factory = MainServiceFactory(
            imageGenerationServiceFactory: LiveImageGenerationServiceFactory()
        )

        servicesManager = MainServicesManager(
            configurationManager: configManager,
            servicesFactory: factory
        )

        // Session
        let sessionStore = MockStateStorage()
        let restoration = MockStateRestorationService()
        sessionManager = SessionManager(
            stateStorage: sessionStore,
            restorationService: restoration
        )

        // Permission - Authorize everything
        let authorizedStatuses: [String: PermissionStatus] = [
            Permissions.microphone.id: .authorized,
            Permissions.speechRecognition.id: .authorized,
            Permissions.photoLibrary.id: .authorized,
        ]
        let mockPermissionService = MockPermissionService(permissionStatuses: authorizedStatuses)
        permissionManager = PermissionManager(service: mockPermissionService)

        // 4. ViewModel
        viewModel = SpeechRecognitionViewModel(
            servicesManager: servicesManager,
            sessionManager: sessionManager
        )

        // Force the desired state
        viewModel.state = state

        // Pre-fill some text for the "speechRecognized" state explicitly if needed
        if case let .speechRecognized(text) = state {
            // We might need to handle this if the VM stores text separately,
            // but in MainActionState, text is associated value.
            print("Preview state set: \(text)")
        }
    }
}

struct SpeechRecognitionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 1. Idle / Waiting
            previewFor(state: .waiting, name: "Waiting")

            // 2. Processing (Recording)
            previewFor(state: .processingSpeech, name: "Recording")

            // 3. Analyzing
            previewFor(state: .analysingSpeech, name: "Analyzing")

            // 4. Recognized
            previewFor(
                state: .speechRecognized("A cute blue robot jumping on a cloud"),
                name: "Recognized"
            )

            // 5. Generating
            previewFor(state: .generatingImage(from: "A cute blue robot"), name: "Generating")

            // 6. Error
            previewFor(
                state: .error("Something went wrong with the microphone"),
                name: "Error Banner"
            )

            // 7. Fatal Error
            previewFor(
                state: .fatalError(.serviceCreationFailed("Mock failure")),
                name: "Fatal Error"
            )
        }
    }

    @MainActor
    private static func previewFor(state: MainActionState, name: String) -> some View {
        let helper = PreviewHelper(state: state)
        return SpeechRecognitionView(
            configManager: helper.configManager,
            permissionManager: helper.permissionManager,
            viewModel: helper.viewModel
        )
        .previewDisplayName(name)
    }
}
