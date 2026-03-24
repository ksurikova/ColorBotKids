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
                .bannerMessageStyle()

            Button(action: action) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.orange.opacity(0.8))
                    .font(.title3)
            }
        }
        .glassyBannerStyle(borderColor: .orange)
        .padding(.horizontal, 20)
    }
}

#Preview {
    ErrorBannerView(message: "An error occurred!", action: {})
}
