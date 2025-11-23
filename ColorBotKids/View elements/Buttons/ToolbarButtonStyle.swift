//
//  ToolbarButtonStyle.swift
//  ColorBotKids
//
//  Created by ksurikova on 13.11.2025.
//
import SwiftUI

struct ToolbarButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 24, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 50, height: 50)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isEnabled
                                ? [color.opacity(0.8), color]
                                : [Color.gray.opacity(0.3), Color.gray.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: isEnabled ? color.opacity(0.4) : .clear,
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == ToolbarButtonStyle {
    static func toolbar(color: Color) -> ToolbarButtonStyle {
        ToolbarButtonStyle(color: color)
    }
}
