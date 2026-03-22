//
//  SpeechConfigurationView+Previews.swift
//  ColorBotKids
//
//  Created by Ксения Филюшкина on 15.03.2026.
//
import Combine
import SwiftUI

struct SpeechConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 1. Loading
            previewFor(state: .loading, name: "Loading")

            // 2. Content (Standard)
            previewFor(
                state: .content(.init(
                    capabilities: .mock(locale: Locale(identifier: "en-US")),
                    missingPermissions: false,
                    canSave: true,
                    warningMessage: nil
                )),
                name: "Content (Valid)"
            )

            // 3. Missing Permissions
            previewFor(
                state: .content(.init(
                    capabilities: .mock(locale: Locale(identifier: "en-US")),
                    missingPermissions: true,
                    canSave: false,
                    warningMessage: nil
                )),
                name: "Missing Permissions"
            )

            // 4. Unsupported Language
            previewFor(
                state: .content(.init(
                    capabilities: .mock(
                        locale: Locale(identifier: "xx-XX"),
                        speechAvailable: false
                    ),
                    missingPermissions: false,
                    canSave: false,
                    warningMessage: "Not Supported"
                )),
                name: "Unsupported Language"
            )

            // 5. Saving
            previewFor(
                state: .saving(.init(
                    capabilities: .mock(locale: Locale(identifier: "en-US")),
                    canSave: true
                )),
                name: "Saving"
            )

            // 6. Error
            previewFor(
                state: .error(.unknown("Something went wrong"), .init(
                    capabilities: .mock(locale: Locale(identifier: "en-US")),
                    canSave: true
                )),
                name: "Error Banner"
            )
        }
    }

    @MainActor
    private static func previewFor(state: SpeechConfigurationViewModel.ScreenState,
                                   name: String) -> some View {
        // Reset Mocks to clean slate
        MockSpeechRecognitionService.reset()
        MockTextToSpeechService.reset()

        // Configure Mocks based on the desired state
        configureMocks(for: state)

        // Use our new powerful MockDependencyContainer
        let container = makeContainer(for: state)

        let configManager = container.mainServicesManager.configurationManager
        let draftService = MockSpeechConfigurationDraftService()

        // Create ViewModel
        let viewModel = SpeechConfigurationViewModel(
            configManager: configManager,
            permissionManager: container.permissionManager,
            draftService: draftService
        )

        // Force the desired state for the preview
        if state == .loading {
            viewModel.stopPipelines()
        }
        viewModel.state = state

        // Also inject dummy content if state is .content to reflect in UI bindings
        if case let .content(content) = state, let caps = content.capabilities {
            viewModel.selectedLocale = caps.locale
        }

        return SpeechConfigurationView(viewModel: viewModel)
            .previewDisplayName(name)
    }

    private static func makeContainer(for state: SpeechConfigurationViewModel
        .ScreenState) -> MockDependencyContainer {
        if case let .content(content) = state, content.missingPermissions {
            // Simulate missing permissions
            return MockDependencyContainer(permissionStatuses: [
                "microphone": .denied,
                "speechRecognition": .denied,
            ])
        }
        // Default container has all authorized
        return MockDependencyContainer()
    }

    private static func configureMocks(for state: SpeechConfigurationViewModel.ScreenState) {
        // Default valid state
        MockSpeechRecognitionService.configure(canCreate: true)

        if case let .content(content) = state {
            if let caps = content.capabilities {
                // Respect the capabilities defined in the preview state
                MockSpeechRecognitionService.configure(
                    canCreate: caps.speechAvailable
                )
                MockTextToSpeechService.configure(
                    isAvailable: caps.ttsAvailable
                )
            }
        }

        // Specific override for unsupported language case if needed
        // (Handled by caps.speechAvailable above usually)
    }
}

// Helper to construct mock capabilities if not present
#if DEBUG
    extension SpeechCapabilities {
        static func mock(locale: Locale, speechAvailable: Bool = true) -> SpeechCapabilities {
            SpeechCapabilities(
                locale: locale,
                speechAvailable: speechAvailable,
                onDeviceAvailable: speechAvailable,
                ttsAvailable: speechAvailable
            )
        }
    }
#endif
