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

            Button(action: action) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.orange.opacity(0.8))
                    .font(.title3)
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
    }
}

#Preview {
    ErrorBannerView(message: "An error occurred!", action: {})
}
