//
//  ConfirmationActionButton.swift
//  ColorBotKids
//
//  Created by ksurikova on 16.11.2025.
//
import SwiftUI

enum ConfirmationActionStyle {
    case primary
    case destructive
    case secondary

    var buttonStyle: any ButtonStyle {
        switch self {
        case .primary: return .confirmPrimary
        case .destructive: return .confirmDestructive
        case .secondary: return .confirmSecondary
        }
    }
}

struct ConfirmationActionButton<S: ButtonStyle>: View {
    let icon: String
    let text: LocalizedStringKey
    let style: S
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .medium))
                Text(text)
                    .confirmationButtonLabel()
            }
        }
        .buttonStyle(style)
    }
}

#Preview("primary") {
    ConfirmationActionButton(
        icon: "checkmark.circle.fill",
        text: "confirmation_action_save",
        style: .confirmPrimary,
        action: {}
    )
}

#Preview("desctructive") {
    ConfirmationActionButton(
        icon: "xmark.circle.fill",
        text: "confirmation_action_dontSave",
        style: .confirmDestructive,
        action: {}
    )
}

#Preview("secondary") {
    ConfirmationActionButton(
        icon: "paintbrush.pointed.fill",
        text: "confirmation_action_keepDrawing",
        style: .confirmSecondary,
        action: {}
    )
}
