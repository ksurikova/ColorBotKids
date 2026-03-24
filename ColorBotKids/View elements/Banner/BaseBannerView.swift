//
//  AppError.swift
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
                .bannerMessageStyle()

            if let onClose {
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.orange.opacity(0.8))
                        .font(.title3)
                }
            }
        }
        .glassyBannerStyle(borderColor: .orange)
        .padding(.horizontal, 20)
    }
}
