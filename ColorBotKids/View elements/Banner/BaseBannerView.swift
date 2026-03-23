//
//  BaseBannerView.swift
//  ColorBotKids
//
//  Created by ksurikova on 23.03.2026.
//
import SwiftUI

struct BaseBannerView: View {
    let message: String
    let icon: Image
    let onClose: (() -> Void)?

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
                .frame(maxWidth: .infinity, alignment: .leading)

            if let onClose {
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.orange.opacity(0.8))
                        .font(.title3)
                }
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
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
}
