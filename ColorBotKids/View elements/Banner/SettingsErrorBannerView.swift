//
//  SettingsErrorBannerView.swift
//  ColorBotKids
//
//  Created by ksurikova on 23.03.2026.
//

import SwiftUI

struct SettingsErrorBannerView: View {
    let message: String
    let onSettingsTapped: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "gear.badge.exclamationmark")
                .font(.title3)
                .foregroundStyle(.pink)

            Text(message)
                .bannerMessageStyle()

            HStack(spacing: 12) {
                Button(action: onSettingsTapped) {
                    Text(String(localized: "common_action_settings", defaultValue: "Settings"))
                }
                .buttonStyle(.capsule(color: .pink))

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary.opacity(0.6))
                        .font(.title3)
                }
            }
        }
        .glassyBannerStyle(borderColor: .pink)
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
        SettingsErrorBannerView(
            message: "Missing API configuration. Please check your settings.",
            onSettingsTapped: {},
            onDismiss: {} // This is just for preview
        )
    }
}
