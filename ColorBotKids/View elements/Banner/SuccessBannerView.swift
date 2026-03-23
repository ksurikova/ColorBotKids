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

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }

            Text(message)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            if let onClose {
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.green.opacity(0.6))
                        .font(.title3)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThickMaterial) // Changed to Material for better overlay look
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.green.opacity(0.3), lineWidth: 2)
                )
        )
        .shadow(color: .green.opacity(0.1), radius: 15, x: 0, y: 8)
        .padding(.horizontal, 20)
    }
}

#Preview {
    SuccessBannerView(message: "It is OK!", onClose: nil)
}
