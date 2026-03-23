//
//  SpeechConfigurationSectionView.swift
//  ColorBotKids
//
//  Created by ksurikova on 8.12.2025.
//
import SwiftUI

struct SpeechConfigurationSectionView: View {
    @ObservedObject var viewModel: SpeechConfigurationViewModel

    var body: some View {
        Section(
            header: Text("settings_title_speechLanguage"),
            footer: Text("settings_description_speechLanguage")
        ) {
            SpeechLanguageSection(
                selectedLocale: $viewModel.selectedLocale,
                supportedLocales: viewModel.pickerLocales
            )

            if let warning = viewModel.state.content.warningMessage {
                CriticalErrorPieceView(
                    title: "settings_errorTitle_speech",
                    text: warning
                )
            }

            SpeechFeaturesSection(
                useOnlyOnDevice: $viewModel.useOnlyOnDevice,
                autoPlayConfirmation: $viewModel.autoPlayConfirmation,
                capabilities: viewModel.state.content.capabilities
            )
            .disabled(viewModel.state.content.warningMessage != nil)
            .opacity(viewModel.state.content.warningMessage == nil ? 1.0 : 0.5)
            .animation(.easeInOut, value: viewModel.state.content.warningMessage)
        }
    }
}
