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
        VStack(spacing: 8) {
            if let errorMessage = viewModel.state.errorMessage {
                ErrorBannerView(message: errorMessage) {
                    viewModel.clearError()
                }
            }

            if let warning = viewModel.ttsWarning {
                let config = warning.bannerConfig
                BaseBannerView(
                    message: config.message,
                    icon: Image(systemName: config.icon),
                    duration: 5.0,
                    onClose: { viewModel.dismissTTSWarning() }
                )
            }
        }
        .padding(.top, 60)
    }
}
