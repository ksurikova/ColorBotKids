//
//  PromptSectionView.swift
//  ColorBotKids
//
//  Created by ksurikova on 9.12.2025.
//
import SwiftUI

struct PromptSectionView: View {
    let recognitionState: MainActionState

    private var currentPrompt: String {
        // If we have a prompt (even from an error state), show it
        if let text = recognitionState.recognizedText {
            return text
        }

        switch recognitionState {
        case .waiting:
            return String(localized: "main_prompt_tapToStart")
        case .processingSpeech:
            return String(localized: "main_prompt_listening")
        case let .analysingSpeech(seconds):
            if let seconds {
                return String(
                    localized: "main_prompt_analyzing_countDown",
                    defaultValue: "Analyzing in \(seconds)..."
                )
            }
            return String(localized: "main_prompt_analyzing")
        case .preparingServices, .fatalError:
            return ""
        default:
            return ""
        }
    }

    var body: some View {
        ZStack {
            PulsingWaveView(isActive: recognitionState.isProcessing)
                .opacity(recognitionState.isProcessing ? 1 : 0)
                .animation(.easeInOut, value: recognitionState.isProcessing)

            ModernPromptCard(text: currentPrompt)
        }
        .frame(height: 180)
    }
}

#Preview("with pulse") {
    PromptSectionView(recognitionState: MainActionState.processingSpeech)
}

#Preview("no pulse") {
    PromptSectionView(recognitionState: MainActionState.speechRecognized("some test prompt"))
}
