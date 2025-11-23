//
//  SpeechConfigurationView.swift
//  ColorBotKids
//
//  Created by ksurikova on 18.11.2025.
//
import SwiftUI

struct SpeechConfigurationView: View {
    @EnvironmentObject private var appModel: AppModel
    @Environment(\.speechServiceType) private var speechServiceType
    @Environment(\.permissionService) private var permissionService
    @State private var isSaving = false
    @State private var error: Error?
    @State private var criticalError: String?
    @State private var showBanner = false

    @State private var settingsModel: SpeechSettingsModel?

    var noSpeechPermissions: Bool {
        !appModel.hasSpeechPermissions
    }

    var body: some View {
        Group {
            if let criticalError {
                criticalErrorView(message: criticalError)
            } else if let settingsModel = Binding($settingsModel) {
                formView(model: settingsModel)
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear(perform: loadInitialValues)
    }

    @ViewBuilder
    private func formView(model: Binding<SpeechSettingsModel>) -> some View {
        VStack(spacing: 24) {
            if let error {
                BaseBannerView(
                    message: error.localizedDescription,
                    icon: Image(systemName: "exclamationmark.triangle.fill"),
                    duration: nil,
                    onClose: { self.error = nil }
                )
            }
            DefaultIcon(
                name: "waveform.circle.fill",
                foregroundStyle: AnyShapeStyle(LinearGradient.bluePurple)
            )

            Text("Setup Speech Recognition").mainStyle()
            SpeechSettingsView(model: model)

            if noSpeechPermissions {
                SpeechPermissionsView(
                    microphoneStatus: $appModel.microphoneStatus,
                    speechRecognitionStatus: $appModel.speechRecognitionStatus
                )
            }
            Button("Save & Continue") {
                saveConfiguration()
            }
            .buttonStyle(.primary)
            .disabled(isSaving || noSpeechPermissions)
        }
        .padding()
    }

    private func loadInitialValues() {
        let supportedLocales = speechServiceType.getSupportedLocales()

        // CRITICAL: Validate we have supported locales
        guard !supportedLocales.isEmpty else {
            criticalError = """
            Speech recognition is not available on this device. \
            This app requires speech recognition to function properly.
            """
            return
        }
        let savedConfig = appModel.currentConfiguration.speechConfig
        settingsModel = SpeechSettingsModel.create(
            supportedLocales: supportedLocales,
            savedConfig: savedConfig
        )
    }

    private func saveConfiguration() {
        guard let model = settingsModel else { return }
        isSaving = true
        error = nil
        let config = SpeechConfiguration(
            language: model.selectedLocale.identifier,
            useOnlyOnDevice: model.useOnlyOnDevice,
            autoPlayConfirmation: model.autoPlayConfirmation
        )
        do {
            try appModel.updateSpeechConfiguration(config)
            // may be we don't need it
            isSaving = false
        } catch {
            self.error = error
            isSaving = false
        }
    }

    @ViewBuilder
    private func criticalErrorView(message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("Critical Error")
                .font(.title)
                .bold()

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button("Go Back") {
                // Handle navigation back
            }
            .buttonStyle(.primary)
        }
        .padding()
    }
}

struct SpeechConfigErrorPreviewWrapper: View {
    init() {
        MockSpeechRecognitionService.supportedLocales = []
    }

    var body: some View {
        SpeechConfigurationView()
            .environment(\.speechServiceType, MockSpeechRecognitionService.self)
            .environment(\.permissionService, MockPermissionService())
            .environmentObject(AppModel.mockWithAI(
                provider: .stabilityAI,
                apiKey: "sk-test-key"
            ))
    }
}

#Preview("Critical error") {
    SpeechConfigErrorPreviewWrapper()
}

struct SpeechConfigTTSPreviewWrapper: View {
    init() {
        MockSpeechRecognitionService.supportedLocales = [
            Locale(identifier: "en-US"),
            Locale(identifier: "fr-FR"),
        ]
        MockTextToSpeechService.isAvailableOverride = true
    }

    var body: some View {
        SpeechConfigurationView()
            .environment(\.speechServiceType, MockSpeechRecognitionService.self)
            .environment(\.permissionService, MockPermissionService())
            .environmentObject(AppModel.mockWithAI(
                provider: .stabilityAI,
                apiKey: "sk-test-key"
            ))
    }
}

#Preview("Not supported TTS") {
    SpeechConfigTTSPreviewWrapper()
}
