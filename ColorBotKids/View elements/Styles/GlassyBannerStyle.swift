//
//  GlassyBannerStyle.swift
//  ColorBotKids
//
//  Created by ksurikova on 23.03.2026.
//
import SwiftUI

struct GlassyBannerStyle: ViewModifier {
    let borderColor: Color

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThickMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(borderColor.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassyBannerStyle(borderColor: Color = .gray) -> some View {
        modifier(GlassyBannerStyle(borderColor: borderColor))
    }
}
