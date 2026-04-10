//
//  ConfigurationContainerView.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.12.2025.
//
import SwiftUI

struct ConfigurationContainerView<Content: View>: View {
    let error: Error?
    let duration: TimeInterval? = 2.0 // auto-dismiss time
    let onDismissError: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 24) {
            if let error {
                BaseBannerView(
                    message: error.localizedDescription,
                    icon: Image(systemName: "exclamationmark.triangle.fill"),
                    onClose: onDismissError
                )
                // The Transition: This tells SwiftUI how to insert/remove the view
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            content
        }
        .padding()
        // The Animation: This ensures the VStack slides other elements down smoothly
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: error != nil)
        // The Timer Logic: Triggered whenever the error changes
        .task(id: error?.localizedDescription) {
            guard error != nil, let duration else { return }

            try? await Task.sleep(for: .seconds(duration))

            // Ensure we only dismiss if the error hasn't changed or been cleared already
            withAnimation {
                onDismissError()
            }
        }
    }
}

#Preview("default") {
    ConfigurationContainerView(
        error: nil,
        onDismissError: {},
        content: {
            Color.blue
        }
    )
}

#Preview("error") {
    ConfigurationContainerView(
        error: AppError
            .configurationFailed(ConfigurationError.aiConfigurationMissing.localizedDescription),
        onDismissError: {},
        content: {
            Color.blue
        }
    )
}
