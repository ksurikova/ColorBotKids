//
//  SpeechRecognitionView.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//

import SwiftUI

struct SpeechRecognitionView: View {
    let permissionManager: PermissionManager
    let configManager: ConfigurationManager
    @ObservedObject private var viewModel: SpeechRecognitionViewModel

    init(
        configManager: ConfigurationManager,
        permissionManager: PermissionManager,
        viewModel: SpeechRecognitionViewModel
    ) {
        self.permissionManager = permissionManager
        self.configManager = configManager
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            BackgroundView()

            VStack {
                HStack {
                    Spacer()
                    SettingsButtonView(showSettings: $viewModel.showSettings)
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
        .sheet(isPresented: $viewModel.showSettings, onDismiss:
            { viewModel.handleSettingsDismissed()
            }, content: {
                SettingsView(configManager: configManager, permissionManager: permissionManager)
            })
        .onDisappear {
            viewModel.ttsService?.stop()
        }
    }
}
