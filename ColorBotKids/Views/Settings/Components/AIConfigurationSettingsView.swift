//
//  AIConfigurationSettingsView.swift
//  ColorBotKids
//
//  Created by ksurikova on 8.12.2025.
//
import SwiftUI

struct AIConfigurationSectionView: View {
    @ObservedObject var viewModel: AIConfigurationViewModel

    var body: some View {
        Section(
            header: Text("settings_label_aiImageGeneration"),
            footer: Text("settings_description_aiImageGeneration")
        ) {
            Picker("settings_label_provider", selection: $viewModel.selectedProvider) {
                ForEach(ImageProvider.allCases, id: \.self) { provider in
                    Text(provider.displayName).tag(provider)
                }
            }

            if viewModel.requiresApiKey {
                APIKeyFieldView(placeholder: "settings_label_apiKey", text: $viewModel.apiKey)
                    .padding()
            }
        }
    }
}

#Preview {
    let mockStorage = MockConfigurationStorage()
    let resolver = SpeechCapabilityResolver(
        speechService: MockSpeechRecognitionService.self,
        ttsService: MockTextToSpeechService.self
    )
    let configManager = ConfigurationManager(storage: mockStorage, resolver: resolver)
    let vm = AIConfigurationViewModel(configManager: configManager)

    return AIConfigurationSectionView(viewModel: vm)
}
