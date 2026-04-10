//
//  ActionButtonsView.swift
//  ColorBotKids
//
//  Created by ksurikova on 9.12.2025.
//
import SwiftUI

struct ActionButtonsView: View {
    let recognitionState: MainActionState
    let showHint: Bool
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
            .overlay(alignment: .top) {
                if showHint {
                    HintBubbleView()
                        // Align the bottom of the hint to the top of the button, plus a tiny gap
                        .alignmentGuide(.top) { d in d[.bottom] + 8 }
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        .allowsHitTesting(false)
                }
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

struct HintBubbleView: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("main_hint")
                .hintStyle()
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.black.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Image(systemName: "triangle.fill")
                .font(.system(size: 10))
                .foregroundStyle(Color.black.opacity(0.8))
                .rotationEffect(.degrees(180))
        }
    }
}

#Preview("processing speech") {
    ActionButtonsView(
        recognitionState: MainActionState.processingSpeech,
        showHint: true,
        onRecord: {},
        onDraw: {}
    )
}

#Preview("speech recognized") {
    ActionButtonsView(
        recognitionState: MainActionState.speechRecognized("some speech"),
        showHint: false,
        onRecord: {},
        onDraw: {}
    )
}

#Preview("speech analyze") {
    ActionButtonsView(
        recognitionState: MainActionState.analysingSpeech,
        showHint: false,
        onRecord: {},
        onDraw: {}
    )
}

#Preview("wait for speech") {
    ActionButtonsView(
        recognitionState: MainActionState.waiting,
        showHint: false,
        onRecord: {},
        onDraw: {}
    )
}
