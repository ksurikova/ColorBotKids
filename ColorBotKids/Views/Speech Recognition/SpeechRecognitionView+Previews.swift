//
//  SpeechRecognitionView+Previews.swift
//  ColorBotKids
//
//  Created by ksurikova on 10.03.2026.
//

import Combine
import SwiftUI

struct SpeechRecognitionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Idle / Waiting
            previewFor(state: .waiting, name: "Waiting")

            // Processing (Recording)
            previewFor(state: .processingSpeech, name: "Recording")

            // Analyzing
            previewFor(state: .analysingSpeech(1), name: "Analyzing")

            // Recognized
            previewFor(
                state: .speechRecognized("A cute blue robot jumping on a cloud"),
                name: "Recognized"
            )

            // Generating
            previewFor(state: .generatingImage(from: "A cute blue robot"), name: "Generating")

            // Temporary Error
            previewFor(
                state: .temporaryError(
                    "Something went wrong with the microphone",
                    prompt: "A cute blue robot jumping on a cloud"
                ),
                name: "Error Banner"
            )

            // Settngs Needed Error
            previewFor(
                state: .configurationRequired(
                    "Check your settings and try again",
                    prompt: "A cute blue robot jumping on a cloud"
                ),
                name: "Fix Configuration"
            )

            // Fatal Error
            previewFor(
                state: .fatalError(.serviceCreationFailed("Mock failure")),
                name: "Fatal Error"
            )
        }
    }

    @MainActor
    private static func previewFor(state: MainActionState, name: String) -> some View {
        let container = MockDependencyContainer()

        // Initialize services for the preview
        let servicesManager = container.mainServicesManager

        // 1. Ensure configuration is loaded (synchronous for mocks)
        servicesManager.configurationManager.load()

        // 2. Create the service stack
        try? servicesManager.prepareServices()

        // 3. Create ViewModel
        let viewModel = SpeechRecognitionViewModel(
            servicesManager: servicesManager,
            sessionManager: container.sessionManager
        )

        // Force the desired state for the preview
        viewModel.state = state

        return SpeechRecognitionView(
            configManager: servicesManager.configurationManager,
            permissionManager: container.permissionManager,
            draftService: container.speechConfigurationDraftService,
            aiDraftService: container.aiConfigurationDraftService,
            viewModel: viewModel
        )
        .previewDisplayName(name)
    }
}
