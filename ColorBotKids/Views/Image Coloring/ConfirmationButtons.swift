//
//  ConfirmationButtons.swift
//  ColorBotKids
//
//  Created by ksurikova on 16.11.2025.
//
import SwiftUI

struct ConfirmationButtons: View {
    let onSave: () -> Void
    let onCancelSave: () -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ConfirmationActionButton(
                icon: "checkmark.circle.fill",
                text: "Save",
                style: .confirmPrimary,
                action: onSave
            )
            ConfirmationActionButton(
                icon: "xmark.circle.fill",
                text: "Don't Save",
                style: .confirmDestructive,
                action: onCancelSave
            )
            ConfirmationActionButton(
                icon: "paintbrush.pointed.fill",
                text: "Keep Drawing",
                style: .confirmSecondary,
                action: onContinue
            )
        }
    }
}

#Preview("desctructive") {
    ConfirmationButtons(
        onSave: {},
        onCancelSave: {},
        onContinue: {}
    )
}
