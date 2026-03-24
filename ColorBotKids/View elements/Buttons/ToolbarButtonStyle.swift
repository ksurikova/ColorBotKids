//
//  ToolbarButtonStyle.swift
//  ColorBotKids
//
//  Created by ksurikova on 13.11.2025.
//
import SwiftUI

struct ToolbarButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.horizontalSizeClass) private var sizeClass
    var color: Color

    private var buttonSize: CGFloat {
        sizeClass == .compact ? 36 : 50
    }

    private var fontSize: CGFloat {
        sizeClass == .compact ? 16 : 24
    }

    private var shadowRadius: CGFloat {
        sizeClass == .compact ? 4 : 8
    }

    private var shadowY: CGFloat {
        sizeClass == .compact ? 2 : 4
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: fontSize, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: buttonSize, height: buttonSize)
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
                        radius: shadowRadius,
                        x: 0,
                        y: shadowY
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
