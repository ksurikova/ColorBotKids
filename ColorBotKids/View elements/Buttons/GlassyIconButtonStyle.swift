//
//  GlassyIconButtonStyle.swift
//  ColorBotKids
//
//  Created by ksurikova on 23.03.2026.
//
import SwiftUI

struct GlassyIconButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .padding(12)
            .background(
                Circle()
                    .fill(.ultraThickMaterial)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
            .foregroundStyle(color)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GlassyIconButtonStyle {
    static func glassyIcon(color: Color = .secondary) -> GlassyIconButtonStyle {
        GlassyIconButtonStyle(color: color)
    }
}
