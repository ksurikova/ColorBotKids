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
                .bannerMessageStyle()

            if let onClose {
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.green.opacity(0.6))
                        .font(.title3)
                }
            }
        }
        .glassyBannerStyle(borderColor: .green)
        .padding(.horizontal, 20)
    }
}

#Preview {
    SuccessBannerView(message: "It is OK!", onClose: nil)
}
