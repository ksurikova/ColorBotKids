//
//  ConfirmationButtonStyle.swift
//  ColorBotKids
//
//  Created by ksurikova on 16.11.2025.
//
import SwiftUI

struct ConfirmationButtonStyle: ButtonStyle {
    enum ButtonType {
        case primary
        case destructive
        case secondary
    }

    let type: ButtonType

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: 70) // Tall button for big icons
            .background(backgroundColor(isPressed: configuration.isPressed))
            .foregroundStyle(foregroundColor)
            .cornerRadius(18)
            .shadow(
                color: Color.black.opacity(configuration.isPressed ? 0.05 : 0.1),
                radius: configuration.isPressed ? 4 : 8,
                y: configuration.isPressed ? 2 : 4
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        let baseColor: Color
        switch type {
        case .primary:
            baseColor = Color(red: 0.4, green: 0.8, blue: 0.6)
        case .destructive:
            baseColor = Color(red: 1.0, green: 0.7, blue: 0.5)
        case .secondary:
            baseColor = Color(red: 0.7, green: 0.7, blue: 0.85)
        }
        return isPressed ? baseColor.opacity(0.8) : baseColor
    }

    private var foregroundColor: Color {
        .white
    }
}

extension ButtonStyle where Self == ConfirmationButtonStyle {
    static var confirmPrimary: ConfirmationButtonStyle {
        ConfirmationButtonStyle(type: .primary)
    }

    static var confirmDestructive: ConfirmationButtonStyle {
        ConfirmationButtonStyle(type: .destructive)
    }

    static var confirmSecondary: ConfirmationButtonStyle {
        ConfirmationButtonStyle(type: .secondary)
    }
}
