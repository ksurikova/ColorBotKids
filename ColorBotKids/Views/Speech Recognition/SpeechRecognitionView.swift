//
//  SpeechRecognitionView.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//

import SwiftUI

struct SpeechRecognitionView: View {
    let configManager: ConfigurationManager
    let permissionManager: PermissionManager
    let draftService: SpeechConfigurationDraftService
    let aiDraftService: AIConfigurationDraftService
    @ObservedObject var viewModel: SpeechRecognitionViewModel

    init(
        configManager: ConfigurationManager,
        permissionManager: PermissionManager,
        draftService: SpeechConfigurationDraftService,
        aiDraftService: AIConfigurationDraftService,
        viewModel: SpeechRecognitionViewModel
    ) {
        self.configManager = configManager
        self.permissionManager = permissionManager
        self.draftService = draftService
        self.aiDraftService = aiDraftService
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            BackgroundView()

            VStack {
                HStack {
                    Spacer()
                    SettingsButtonView(showSettings: $viewModel.showSettings)
                        .disabled(viewModel.state.isBlocked)
                        .opacity(viewModel.state.isBlocked ? 0.5 : 1.0)
                }
                .padding()

                Spacer()

                VStack(spacing: 32) {
                    TitleSectionView()
                    PromptSectionView(recognitionState: viewModel.state)

                    if viewModel.canSpeakText {
                        HearButtonView(action: viewModel.speakCurrentText)
                    }

                    ActionButtonsView(
                        recognitionState: viewModel.state,
                        onRecord: { Task { await viewModel.toggleRecording() } },
                        onDraw: { Task { await viewModel.generateImage() } }
                    )
                }
                Spacer()
            }

            // Overlays
            if case .generatingImage = viewModel.state {
                LoadingOverlayView(message: String(localized: "main_message_loadingImage"))
            }
        }
        .overlay(alignment: .top) {
            NotificationStackView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showSettings, onDismiss: {
            viewModel.handleSettingsDismissed()
        }, content: {
            SettingsView(
                configManager: configManager,
                permissionManager: permissionManager,
                draftService: draftService,
                aiDraftService: aiDraftService
            )
        })
        .onDisappear {
            viewModel.ttsService?.stop()
        }
    }
}
