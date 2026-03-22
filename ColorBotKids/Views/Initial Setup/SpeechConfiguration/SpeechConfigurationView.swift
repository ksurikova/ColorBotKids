//
//  SpeechConfigurationView.swift
//  ColorBotKids
//
//  Created by ksurikova on 18.11.2025.
//
import SwiftUI

struct SpeechConfigurationView: View {
    @StateObject private var viewModel: SpeechConfigurationViewModel

    init(
        configManager: ConfigurationManager,
        permissionManager: PermissionManager,
        draftService: SpeechConfigurationDraftService
    ) {
        _viewModel =
            StateObject(wrappedValue: SpeechConfigurationViewModel(
                configManager: configManager,
                permissionManager: permissionManager,
                draftService: draftService
            ))
    }

    // Init for Previews / Dependency Injection
    init(viewModel: SpeechConfigurationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ConfigurationContainerView(
            error: viewModel.state.error.map { $0 as Error },
            onDismissError: viewModel.dismissError,
            content: {
                // Wrap the informational content in a ScrollView
                ScrollView {
                    VStack(spacing: 20) {
                        OnboardingHeaderView(
                            icon: "waveform.circle.fill",
                            title: "onboarding_title_speechConfig"
                        )

                        // Language Section
                        SpeechLanguageSection(
                            selectedLocale: $viewModel.selectedLocale,
                            supportedLocales: viewModel.supportedLocales
                        )

                        // Features Section (Toggles)
                        SpeechFeaturesSection(
                            useOnlyOnDevice: $viewModel.useOnlyOnDevice,
                            autoPlayConfirmation: $viewModel.autoPlayConfirmation,
                            capabilities: viewModel.state.content.capabilities
                        )

                        // Critical Error (Language not supported)
                        if let caps = viewModel.state.content.capabilities, !caps.isCriticalValid {
                            WarningPieceView(
                                text: "Speech recognition is not supported for this language."
                            )
                        }

                        // Permissions
                        if viewModel.state.content.missingPermissions {
                            SpeechPermissionsSection(
                                permissionManager: viewModel.permissionManager
                            )
                        }
                    }
                    // Add vertical padding so content doesn't touch the edges of the scroll view
                    .padding(.vertical, 4)
                }
                .scrollBounceBehavior(.basedOnSize)

                // removed the Spacer() because the ScrollView takes up available space

                // The Save button remains OUTSIDE the ScrollView
                // This keeps it pinned to the bottom (Sticky Footer)
                ConfigurationActionButton(
                    isEnabled: viewModel.state.content.canSave,
                    isProcessing: viewModel.state.isSaving,
                    action: viewModel.save
                )
                .padding(.top, 8)
            }
        )
    }
}
