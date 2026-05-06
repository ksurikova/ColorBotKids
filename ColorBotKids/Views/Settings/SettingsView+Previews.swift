//
//  SettingsView+Previews.swift
//  ColorBotKids
//
//  Created by ksurikova on 23.03.2026.
//
import Combine
import SwiftUI

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 1. Default State (Happy Path)
            previewFor(state: .default, name: "Default")

            // 2. Missing Permissions
            previewFor(state: .missingPermissions, name: "Missing Permissions")

            // 3. Simulated Error (e.g. Speech Config Error)
            previewFor(state: .error, name: "Error State")
        }
    }

    enum PreviewState {
        case `default`
        case missingPermissions
        case error
    }

    @MainActor
    private static func previewFor(state: PreviewState, name: String) -> some View {
        // Reset Mocks
        MockSpeechRecognitionService.reset()
        MockTextToSpeechService.reset()

        // Configure Mocks
        configureMocks(for: state)

        // Create Container
        let container = makeContainer(for: state)
        let builder = DefaultViewModelBuilder(dependencies: container)

        // Create ViewModel
        let viewModel = builder.makeSettingsViewModel()

        // Manipulate ViewModel to reflect desired state
        switch state {
        case .default:
            // Valid state
            viewModel.aiViewModel.selectedProvider = .openAI
            viewModel.aiViewModel.apiKey = "sk-preview-key-123"

        case .missingPermissions:
            // handled by container
            break

        case .error:
            // Inject an error via one of the children or force save failure
            // But since error flows up from children, let's set a child state to error
            // However, child VMs states are usually derived.
            // We can force the parent 'error' property if it was mutable, but it is private(set).
            // So we rely on the child producing it.
            // SpeechConfigurationViewModel.state is @Published.
            viewModel.speechViewModel.state = .error(
                .unknown(String.localized("common_unknown_error")),
                viewModel.speechViewModel.state.content
            )
        }

        return SettingsView(viewModel: viewModel)
            .previewDisplayName(name)
    }

    private static func makeContainer(for state: PreviewState) -> MockDependencyContainer {
        if state == .missingPermissions {
            return MockDependencyContainer(permissionStatuses: [
                "microphone": .denied,
                "speechRecognition": .denied,
            ])
        }
        // Default container
        return MockDependencyContainer()
    }

    private static func configureMocks(for state: PreviewState) {
        MockSpeechRecognitionService.configure(canCreate: true)
        MockTextToSpeechService.configure(isAvailable: true)
    }
}
