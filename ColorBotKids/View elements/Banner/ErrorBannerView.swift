//
//  ErrorBannerView.swift
//  ColorBotKids
//
//  Created by ksurikova on 21.10.2025.
//
import SwiftUI

struct ErrorBannerView: View {
    let message: String
    let action: () -> Void
    @State private var isVisible = false

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(.orange)

            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(3)

            Spacer()
            CloseButton(isVisible: $isVisible, action: action)
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
        .offset(y: isVisible ? 0 : -20)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isVisible = true
            }
        }
    }
}

#Preview {
    ErrorBannerView(message: "An error occurred!", action: {})
}
