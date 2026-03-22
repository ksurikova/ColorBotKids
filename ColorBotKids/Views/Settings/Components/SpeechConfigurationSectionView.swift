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
                supportedLocales: viewModel.supportedLocales
            )

            SpeechFeaturesSection(
                useOnlyOnDevice: $viewModel.useOnlyOnDevice,
                autoPlayConfirmation: $viewModel.autoPlayConfirmation,
                capabilities: viewModel.capabilities
            )

            if let caps = viewModel.capabilities, !caps.isCriticalValid {
                WarningPieceView(text: "speech_error_languageNotSupported")
            }
        }
    }
}
