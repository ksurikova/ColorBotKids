//
//  ConfigurationContainerView.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.12.2025.
//
import SwiftUI

struct ConfigurationContainerView<Content: View>: View {
    let error: Error?
    let onDismissError: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 24) {
            if let error {
                BaseBannerView(
                    message: error.localizedDescription,
                    icon: Image(systemName: "exclamationmark.triangle.fill"),
                    duration: nil,
                    onClose: onDismissError
                )
            }
            content
        }
        .padding()
    }
}
