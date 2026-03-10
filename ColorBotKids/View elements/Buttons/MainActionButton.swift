//
//  MainActionButton.swift
//  ColorBotKids
//
//  Created by ksurikova on 31.10.2025.
//
import SwiftUI

struct MainActionButton: View {
    let icon: String
    let label: LocalizedStringKey
    let color: Color
    var isActive: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    // Pulsing background when active
                    if isActive {
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 90, height: 90)
                            .scaleEffect(1.2)
                            .animation(
                                .easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true),
                                value: isActive
                            )
                    }
                    // Main icon circle
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
                        .frame(width: 80, height: 80)
                        .shadow(
                            color: isEnabled ? color.opacity(0.4) : .clear,
                            radius: isActive ? 20 : 15,
                            x: 0,
                            y: 8
                        )

                    Image(systemName: icon)
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.white)
                }

                Text(label)
                    .labelStyle()
                    .foregroundColor(isEnabled ? .primary : .secondary)
            }
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

#Preview("active") {
    MainActionButton(icon: "mic.fill", label: "common_action_stop",
                     color: .blue, isActive: true, isEnabled: true, action: {})
}

#Preview("not active") {
    MainActionButton(icon: "paintbrush.pointed.fill", label: "common_action_draw",
                     color: .green, isActive: false, isEnabled: false, action: {})
}
