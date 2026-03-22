//
//  ConfigurationActionButton.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.12.2025.
//
import SwiftUI

struct ConfigurationActionButton: View {
    let title: LocalizedStringKey
    let isEnabled: Bool
    let isProcessing: Bool
    let action: () -> Void

    init(
        _ title: LocalizedStringKey = "common_action_saveContinue",
        isEnabled: Bool = true,
        isProcessing: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.isProcessing = isProcessing
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                if isProcessing {
                    ProgressView()
                        .tint(.white)
                }
                Text(title)
            }
        }
        .buttonStyle(.primary)
        .disabled(!isEnabled || isProcessing)
    }
}

#Preview("active") {
    ConfigurationActionButton(action: {})
}
