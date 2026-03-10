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
        switch recognitionState {
        case .waiting:
            return String(localized: "main_prompt_tapToStart")
        case .processingSpeech:
            return String(localized: "main_prompt_listening")
        case .analysingSpeech:
            return String(localized: "main_prompt_analyzing")
        case let .speechRecognized(text), let .generatingImage(from: text):
            return text
        case .error, .preparingServices, .fatalError:
            return ""
        }
    }

    var body: some View {
        VStack {
            Spacer()
            ZStack {
                PulsingWaveView(isActive: recognitionState.isProcessing)
                    .opacity(recognitionState.isProcessing ? 1 : 0)
                    .animation(.easeInOut, value: recognitionState.isProcessing)

                ModernPromptCard(text: currentPrompt)
            }
            .frame(height: 180)
            Spacer()
        }
    }
}

#Preview("with pulse") {
    PromptSectionView(recognitionState: MainActionState.processingSpeech)
}

#Preview("no pulse") {
    PromptSectionView(recognitionState: MainActionState.speechRecognized("some test prompt"))
}
