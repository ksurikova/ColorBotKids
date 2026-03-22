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
            viewModel: viewModel
        )
        .previewDisplayName(name)
    }
}
