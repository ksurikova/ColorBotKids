//
//  CancelButtonStyle.swift
//  ColorBotKids
//
//  Created by ksurikova on 22.10.2025.
//
import SwiftUI

struct CancelButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17))
            .foregroundStyle(.secondary)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == CancelButtonStyle {
    static var cancel: CancelButtonStyle { CancelButtonStyle() }
}
