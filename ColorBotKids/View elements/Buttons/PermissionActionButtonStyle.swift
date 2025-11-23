//
//  PermissionActionButtonStyle.swift
//  ColorBotKids
//
//  Created by ksurikova on 8.11.2025.
//
import SwiftUI

struct PermissionActionButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PermissionActionButtonStyle {
    static func permissionAction(color: Color) -> PermissionActionButtonStyle {
        PermissionActionButtonStyle(color: color)
    }
}
