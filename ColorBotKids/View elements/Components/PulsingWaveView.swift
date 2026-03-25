//
//  PulsingWaveView.swift
//  ColorBotKids
//
//  Created by Ксения Филюшкина on 25.10.2025.
//
//
import SwiftUI

struct PulsingWaveView: View {
    var isActive: Bool

    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [.blue.opacity(0.8), .purple.opacity(0.1)],
                    center: .center,
                    startRadius: 20,
                    endRadius: 60
                )
            )
            .frame(width: 120, height: 120)
            .scaleEffect(scale)
            .opacity(opacity)
            .onChange(of: isActive) {
                if isActive {
                    startAnimation()
                } else {
                    stopAnimation()
                }
            }
            .onAppear {
                if isActive { startAnimation() }
            }
    }

    private func startAnimation() {
        withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) {
            scale = 2.0
            opacity = 0.0
        }
    }

    private func stopAnimation() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 1.0
            opacity = 1.0
        }
    }
}

#Preview {
    PulsingWaveView(isActive: false)
}
