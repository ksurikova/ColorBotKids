//
//  SpeechSettingsView.swift
//  ColorBotKids
//
//  Created by ksurikova on 18.11.2025.
//
import SwiftUI

struct SpeechSettingsView: View {
    @Environment(\.speechServiceType) private var speechServiceType
    @Environment(\.textToSpeechServiceType) private var ttsServiceType

    @Binding var model: SpeechSettingsModel

    // Debounce task
    @State private var validationTask: Task<Void, Never>?

    // Track last validated values to avoid unnecessary work and state loops
    @State private var lastValidatedLocaleIdentifier: String?
    @State private var lastValidatedUseOnlyOnDevice: Bool?

    // Create a Binding to the selectedLocale subproperty to avoid using `$form.selectedLocale`
    // which can be problematic
    private var selectedLocaleBinding: Binding<Locale> {
        Binding<Locale>(
            get: { model.selectedLocale },
            set: { newValue in
                model.selectedLocale = newValue
            }
        )
    }

    var body: some View {
        HStack {
            Text("Language").plainStyle()
            Picker("Language", selection: selectedLocaleBinding) {
                ForEach(model.supportedLocales, id: \.identifier) { locale in
                    Text(locale.localizedDisplayName)
                        .tag(locale)
                }
            }
            .defaultStyle()
            .onChange(of: model.selectedLocale) {
                scheduleValidation()
            }
        }

        Toggle("Use On-Device Recognition Only", isOn: $model.useOnlyOnDevice)
            .padding(4)
            .onChange(of: model.useOnlyOnDevice) {
                scheduleValidation()
            }

        if model.ttsUnavailableForLocale {
            Text("Text-To-Speech is not available for this language.")
                .font(.caption)
                .foregroundColor(.red)
                .padding(.top, 2)
        }

        Toggle("Auto-Play Confirmation", isOn: $model.autoPlayConfirmation)
            .padding(4)
            .disabled(model.ttsUnavailableForLocale)
    }

    private func scheduleValidation() {
        // Cancel any pending validation
        validationTask?.cancel()

        // Start a new debounce task
        validationTask = Task { @MainActor in
            // debounce interval 250ms
            do {
                try await Task.sleep(nanoseconds: 250_000_000)
            } catch {
                // Task was cancelled — nothing to do
                return
            }
            validateIfNeeded()
        }
    }

    @MainActor
    private func validateIfNeeded() {
        let currentLocaleId = model.selectedLocale.identifier
        let currentOnDevice = model.useOnlyOnDevice

        if lastValidatedLocaleIdentifier == currentLocaleId,
           lastValidatedUseOnlyOnDevice == currentOnDevice {
            return
        }

        performValidation()

        lastValidatedLocaleIdentifier = currentLocaleId
        lastValidatedUseOnlyOnDevice = currentOnDevice
    }

    @MainActor
    private func performValidation() {
        let speechSettings = SpeechRecognitionSettings(
            locale: model.selectedLocale,
            requiresOnDevice: model.useOnlyOnDevice
        )

        if !speechServiceType.canCreateWithCurrentSettings(speechSettings) {
            if model.useOnlyOnDevice {
                model.useOnlyOnDevice = false
            }
        }

        let ttsSettings = TextToSpeechSettings(locale: model.selectedLocale)
        let ttsAvailable = ttsServiceType.isAvailableWithCurrentSettings(ttsSettings)

        if model.ttsUnavailableForLocale == !ttsAvailable {
            // no change
        } else {
            model.ttsUnavailableForLocale = !ttsAvailable
        }

        if !ttsAvailable {
            if model.autoPlayConfirmation {
                model.autoPlayConfirmation = false
            }
        }
    }
}

struct SpeechSettingsTTSPreviewWrapper: View {
    init(textToSpeechSupported: Bool) {
        MockTextToSpeechService.isAvailableOverride = textToSpeechSupported
    }

    var body: some View {
        let settingsModel = SpeechSettingsModel.create(
            supportedLocales: [
                Locale(identifier: "en-US"),
                Locale(identifier: "es-ES"),
                Locale(identifier: "fr-FR"),
            ], savedConfig: SpeechConfiguration(
                language: "es-ES",
                useOnlyOnDevice: true,
                autoPlayConfirmation: true
            )
        )
        SpeechSettingsView(model: Binding.constant(settingsModel))
            .environment(\.speechServiceType, MockSpeechRecognitionService.self)
            .environment(\.textToSpeechServiceType, MockTextToSpeechService.self)
    }
}

#Preview("Not supported TTS") {
    SpeechSettingsTTSPreviewWrapper(textToSpeechSupported: false)
}

#Preview("supported TTS") {
    SpeechSettingsTTSPreviewWrapper(textToSpeechSupported: true)
}
