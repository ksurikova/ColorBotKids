//
//  CapsuleButtonStyle.swift
//  ColorBotKids
//
//  Created by ksurikova on 23.03.2026.
//
import SwiftUI

struct CapsuleButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.bold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(
                        configuration.isPressed
                            ? color.opacity(0.3)
                            : color.opacity(0.15)
                    )
            )
            .foregroundStyle(color)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == CapsuleButtonStyle {
    static func capsule(color: Color = .blue) -> CapsuleButtonStyle {
        CapsuleButtonStyle(color: color)
    }
}
