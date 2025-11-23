//
//  SuccessBannerView.swift
//  ColorBotKids
//
//  Created by ksurikova on 13.11.2025.
//
import SwiftUI

struct SuccessBannerView: View {
    let message: String
    let onClose: (() -> Void)?
    @State private var isVisible = false
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 16) {
            // Animated checkmark with celebration effect
            ZStack {
                // Pulsing background circle
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .scaleEffect(isAnimating ? 1.3 : 1.0)
                    .opacity(isAnimating ? 0 : 1)

                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
            }

            Text(message)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            if onClose != nil {
                Button(action: {
                    hide()
                    onClose?()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.green.opacity(0.6))
                        .font(.title3)
                })
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.green.opacity(0.1), Color.green.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.green.opacity(0.6), Color.green.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: .green.opacity(0.2), radius: 15, x: 0, y: 8)
        .padding(.horizontal, 20)
        .offset(y: isVisible ? 0 : -20)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            show()
            // Celebration animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                isAnimating = true
            }
            withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }

    // MARK: - Helpers

    func show() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isVisible = true
        }
    }

    func hide() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isVisible = false
        }
    }
}
