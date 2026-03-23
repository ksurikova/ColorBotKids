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
        _viewModel = StateObject(wrappedValue: SpeechConfigurationViewModel(
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
            onDismissError: viewModel.dismissError
        ) {
            ScrollView {
                VStack(spacing: 24) {
                    OnboardingHeaderView(
                        icon: "waveform.circle.fill",
                        title: "onboarding_title_speechConfig"
                    )

                    // Language Picker (Uses the safe 'pickerLocales' list)
                    SpeechLanguageSection(
                        selectedLocale: $viewModel.selectedLocale,
                        supportedLocales: viewModel.pickerLocales
                    )

                    // Error/Warning Handling
                    if let warning = viewModel.state.content.warningMessage {
                        CriticalErrorPieceView(
                            title: "settings_errorTitle_speech",
                            text: warning
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        ))
                        // Trigger a light vibration when an error appears
                        .sensoryFeedback(
                            .error,
                            trigger: viewModel.state.content.warningMessage != nil
                        )
                    }

                    // Features Section (Toggles)
                    // We always show this, but the VM handles internal state
                    // (e.g., turning off 'On-Device' if not supported).
                    SpeechFeaturesSection(
                        useOnlyOnDevice: $viewModel.useOnlyOnDevice,
                        autoPlayConfirmation: $viewModel.autoPlayConfirmation,
                        capabilities: viewModel.state.content.capabilities
                    )
                    .opacity(viewModel.state.content.warningMessage == nil ? 1.0 : 0.5)
                    .disabled(viewModel.state.content.warningMessage != nil)
                    .animation(.easeInOut, value: viewModel.state.content.warningMessage)

                    // Permissions (Only if the VM flags them as missing)
                    if viewModel.state.content.missingPermissions {
                        SpeechPermissionsSection(
                            permissionManager: viewModel.permissionManager
                        )
                    }
                }
                .padding(.vertical, 8)
                .animation(.default, value: viewModel.state.content)
            }
            .scrollBounceBehavior(.basedOnSize)

            // Sticky Footer Button
            ConfigurationActionButton(
                isEnabled: viewModel.canSave,
                isProcessing: viewModel.state.isSaving,
                action: viewModel.save
            )
            .padding(.top, 8)
        }
    }
}
