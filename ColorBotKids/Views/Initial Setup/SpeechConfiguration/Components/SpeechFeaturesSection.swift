//
//  SpeechFeaturesSection.swift
//  ColorBotKids
//
//  Created by ksurikova on 9.02.2026.
//
import SwiftUI

struct SpeechFeaturesSection: View {
    @Binding var useOnlyOnDevice: Bool
    @Binding var autoPlayConfirmation: Bool
    let capabilities: SpeechCapabilities?

    var body: some View {
        VStack(spacing: 16) {
            // On-Device Toggle
            VStack(alignment: .leading, spacing: 8) {
                Toggle("settings_label_onDeviceRecognition", isOn: $useOnlyOnDevice)
                    .padding(4)
                    // Disable if capability says so
                    .disabled(!(capabilities?.onDeviceAvailable ?? false))

                if let result = capabilities, !result.onDeviceAvailable {
                    WarningPieceView(text: "settings_warning_onDeviceUnavailable")
                }
            }

            // AutoPlay Toggle
            VStack(alignment: .leading, spacing: 8) {
                Toggle("settings_label_autoplay", isOn: $autoPlayConfirmation)
                    .padding(4)
                    // Disable if capability says so
                    .disabled(!(capabilities?.ttsAvailable ?? false))

                if let result = capabilities, !result.ttsAvailable {
                    WarningPieceView(text: "settings_warning_ttsUnavailable")
                }
            }
        }
    }
}
