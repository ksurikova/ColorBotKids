//
//  ActionButtonsView.swift
//  ColorBotKids
//
//  Created by ksurikova on 9.12.2025.
//
import SwiftUI

struct ActionButtonsView: View {
    let recognitionState: MainActionState
    let onRecord: () async -> Void
    let onDraw: () async -> Void

    private var enableDrawButton: Bool {
        // We must have text to draw
        guard recognitionState.recognizedText != nil else { return false }

        // If configuration is broken (e.g. Auth error), block the action until fixed
        if case .configurationRequired = recognitionState {
            return false
        }

        return true
    }

    var body: some View {
        HStack(spacing: 24) {
            MainActionButton(
                icon: recognitionState == .processingSpeech ? "mic.fill" : "mic.circle.fill",
                label: recognitionState == .processingSpeech ? "main_action_stop" :
                    "main_action_record",
                color: recognitionState == .processingSpeech ? .green : .blue,
                isActive: recognitionState == .processingSpeech,
                isEnabled: recognitionState.canToggleRecognition
            ) {
                Task { await onRecord() }
            }

            MainActionButton(
                icon: "paintbrush.pointed.fill",
                label: "main_action_draw",
                color: .purple,
                isEnabled: enableDrawButton
            ) {
                Task { await onDraw() }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 50)
    }
}

#Preview("processing speech") {
    ActionButtonsView(
        recognitionState: MainActionState.processingSpeech,
        onRecord: {},
        onDraw: {}
    )
}

#Preview("speech recognized") {
    ActionButtonsView(
        recognitionState: MainActionState.speechRecognized("some speech"),
        onRecord: {},
        onDraw: {}
    )
}

#Preview("speech analyze") {
    ActionButtonsView(
        recognitionState: MainActionState.analysingSpeech,
        onRecord: {},
        onDraw: {}
    )
}

#Preview("wait for speech") {
    ActionButtonsView(
        recognitionState: MainActionState.waiting,
        onRecord: {},
        onDraw: {}
    )
}
