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
                ZStack(alignment: .bottomLeading) {
                    ActionButtonsView(
                        recognitionState: viewModel.state,
                        onRecord: { Task { await viewModel.toggleRecording() } },
                        onDraw: { Task { await viewModel.generateImage() } }
                    )
                    .padding(.bottom)

                    // Hint bubble aligned over the left button (Record/Stop)
                    if viewModel.showRecordingHint {
                        VStack(spacing: 4) {
                            Text("Tap when done!")
                                .font(.system(.subheadline, design: .rounded).bold())
                                .foregroundStyle(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.black.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            Image(systemName: "triangle.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.black.opacity(0.8))
                                .rotationEffect(.degrees(180))
                        }
                        .padding(.leading, 40) // Approximate alignment with left button center
                        .padding(.bottom, 125) // Position above the button
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        .allowsHitTesting(false)
                    }
                }
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
