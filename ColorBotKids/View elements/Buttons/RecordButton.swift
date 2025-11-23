//
//  RecordButton.swift
//  ColorBotKids
//
//  Created by ksurikova on 25.10.2025.
//
import SwiftUI

struct RecordButton: View {
    let state: RecognitionState
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(color)
                .opacity(opacity)
                .animation(.easeInOut(duration: 0.25), value: state)
        }
        .disabled(!state.canRecognize)
    }
}

private extension RecordButton {
    var iconName: String {
        switch state {
        case .processingSpeech:
            return "waveform.circle.fill"
        default:
            return "waveform.circle"
        }
    }

    var color: Color {
        switch state {
        case .waiting:
            return .blue // Primary action color - "tap me!"
        case .processingSpeech:
            return .red // Recording/active state
        case .speechRecognized:
            return .green // Success indicator
        case .error, .analysingSpeech:
            return .gray // Disabled
        }
    }

    var opacity: Double {
        state.canRecognize ? 1.0 : 0.4
    }
}

#Preview("processing") {
    RecordButton(state: .processingSpeech, action: {})
}

#Preview("ready to work") {
    RecordButton(state: .waiting, action: {})
}
