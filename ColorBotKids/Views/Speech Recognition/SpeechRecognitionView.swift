//
//  SpeechRecognitionView.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//

import SwiftUI

struct SpeechRecognitionView<SettingsView: View>: View {
    @StateObject private var viewModel: SpeechRecognitionViewModel

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private let settingsViewFactory: () -> SettingsView

    init(
        viewModel: SpeechRecognitionViewModel,
        @ViewBuilder settingsViewFactory: @escaping () -> SettingsView
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.settingsViewFactory = settingsViewFactory
    }

    var body: some View {
        ZStack {
            BackgroundView()

            VStack {
                HStack {
                    Spacer()
                    SettingsButtonView(
                        showSettings: $viewModel.showSettings,
                        state: viewModel.state
                    )
                }
                .padding()

                Spacer()

                // Main content centered vertically
                VStack(spacing: 32) {
                    TitleSectionView()
                    PromptSectionView(
                        recognitionState: viewModel.state
                    )

                    HearButtonView(action: viewModel.speakCurrentText)
                        .opacity(viewModel.canSpeakText ? 1 : 0)
                }

                Spacer()

                // Pinned to the bottom
                ActionButtonsView(
                    recognitionState: viewModel.state,
                    showHint: viewModel.showRecordingHint,
                    onRecord: { Task { await viewModel.toggleRecording() } },
                    onDraw: { Task { await viewModel.generateImage() } }
                )
                .padding(.bottom)
            }

            // Overlays
            if case .generatingImage = viewModel.state {
                LoadingOverlayView(message: String(localized: "main_message_loadingImage"))
            }
        }
        .safeAreaInset(edge: .top) {
            // This automatically respects the safe area and pushes your
            // main content down so it doesn't overlap
            NotificationStackView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showSettings, onDismiss: {
            viewModel.handleSettingsDismissed()
        }, content: {
            // We just call the factory. It gives us the SettingsView
            // already injected with its ViewModel
            settingsViewFactory()
        })
        .onDisappear {
            viewModel.ttsService?.stop()
        }
    }
}
