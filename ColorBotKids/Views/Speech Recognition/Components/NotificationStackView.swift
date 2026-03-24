//
//  NotificationStackView.swift
//  ColorBotKids
//
//  Created by ksurikova on 18.02.2026.
//

import SwiftUI

struct NotificationStackView: View {
    @ObservedObject var viewModel: SpeechRecognitionViewModel

    var body: some View {
        VStack(spacing: 12) { // Increased spacing for better legibility in overlays
            // 1. Configuration/Auth Banner
            if let configMessage = viewModel.state.configurationRequiredMessage {
                SettingsErrorBannerView(
                    message: configMessage,
                    onSettingsTapped: { viewModel.showSettings = true },
                    onDismiss: { viewModel.clearError() }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // 2. Error Banner
            if let errorMessage = viewModel.state.errorMessage {
                ErrorBannerView(
                    message: errorMessage,
                    action: { viewModel.clearError() }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // 3. TTS Warning Banner
            if let warning = viewModel.ttsWarning {
                let config = warning.bannerConfig
                BaseBannerView(
                    message: config.message,
                    icon: Image(systemName: config.icon),
                    onClose: { viewModel.dismissTTSWarning() }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(
            .spring(response: 0.4, dampingFraction: 0.8),
            value: viewModel.state
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.ttsWarning != nil)
        // Add timer for the warning to auto-hide
        .task(id: viewModel.ttsWarning?.id) {
            guard viewModel.ttsWarning != nil else { return }
            try? await Task.sleep(for: .seconds(4))
            withAnimation {
                viewModel.dismissTTSWarning()
            }
        }
    }
}
