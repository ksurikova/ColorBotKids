//
//  SpeechConfigurationView.swift
//  ColorBotKids
//
//  Created by ksurikova on 18.11.2025.
//
import SwiftUI

struct SpeechConfigurationView: View {
    @ObservedObject private var viewModel: SpeechConfigurationViewModel

    init(viewModel: SpeechConfigurationViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ConfigurationContainerView(
            error: viewModel.error.map { $0 as Error },
            onDismissError: viewModel.dismissError,
            content: {
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
                    capabilities: viewModel.capabilities
                )

                // Critical Error (Language not supported)
                if let caps = viewModel.capabilities, !caps.isCriticalValid {
                    WarningPieceView(text: "Speech recognition is not supported for this language.")
                }

                Spacer()

                // Permissions
                if viewModel.missingPermissions {
                    SpeechPermissionsSection(
                        permissionManager: viewModel.permissionManager
                    )
                }
                // Save button
                ConfigurationActionButton(
                    isEnabled: viewModel.canSave,
                    isProcessing: viewModel.isSaving,
                    action: viewModel.save
                )
                Spacer()
            }
        )
    }
}
