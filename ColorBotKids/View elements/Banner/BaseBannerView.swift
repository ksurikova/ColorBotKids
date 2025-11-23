//
//  BaseBannerView.swift
//  ColorBotKids
//
//  Created by ksurikova on 24.10.2025.
//
import SwiftUI

struct BaseBannerView: View {
    let message: String
    let icon: Image
    let duration: TimeInterval?
    let onClose: (() -> Void)?

    @State private var isVisible = false

    var body: some View {
        HStack(spacing: 16) {
            icon
                .font(.title3)
                .foregroundColor(.orange)
            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
            if onClose != nil {
                Button(action: {
                    hide()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.orange.opacity(0.8))
                        .font(.title3)
                })
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThickMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.orange.opacity(0.5), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
        .padding(.horizontal, 20)
        .offset(y: isVisible ? 0 : -200) // Increased offset for a more pronounced animation
        .opacity(isVisible ? 1 : 0)
        .onAppear(perform: show)
        .task {
            // If a duration is provided, hide after that time
            if let duration, duration > 0 {
                try? await Task.sleep(for: .seconds(duration))
                hide()
            }
        }
    }

    // MARK: - Helpers

    private func show() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isVisible = true
        }
    }

    private func hide() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isVisible = false
        }
        // Use an async task to allow the animation to finish before calling onClose
        if let onClose {
            Task {
                try? await Task.sleep(for: .seconds(0.5))
                onClose()
            }
        }
    }
}

#Preview("Auto-dismissing banner") {
    BaseBannerView(message: "Operation was successful. This will disappear.",
                   icon: Image(systemName: "checkmark.circle.fill"),
                   duration: 3.0,
                   onClose: { print("Banner closed") })
}

#Preview("Manual close banner") {
    BaseBannerView(message: "Unexpected error happens. Please close manually.",
                   icon: Image(systemName: "exclamationmark.triangle.fill"),
                   duration: nil, // Stays until closed
                   onClose: { print("Banner closed") })
}
