//
//  SettingsButtonView.swift
//  ColorBotKids
//
//  Created by ksurikova on 9.12.2025.
//
import SwiftUI

struct SettingsButtonView: View {
    @Binding var showSettings: Bool
    let state: MainActionState

    private var isDisabled: Bool {
        switch state {
        case .preparingServices, .fatalError, .analysingSpeech, .generatingImage, .processingSpeech:
            return true
        case .configurationRequired, .temporaryError, .waiting, .speechRecognized:
            return false
        }
    }

    var body: some View {
        HStack {
            Spacer()
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
            }
            .buttonStyle(.glassyIcon(color: .secondary))
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .padding(.top, 40)
    }
}

#Preview("") {
    SettingsButtonView(showSettings: .constant(true), state: .waiting)
}
