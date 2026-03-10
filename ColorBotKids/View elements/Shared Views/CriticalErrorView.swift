//
//  CriticalErrorView.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.12.2025.
//
import SwiftUI

struct CriticalErrorView: View {
    let message: String
    var onGoBack: (() -> Void)?

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("common_errorTitle_critical")
                .font(.title)
                .bold()

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            if let onGoBack {
                Button("common_action_goBack", action: onGoBack)
                    .buttonStyle(.primary)
            }
        }
        .padding()
    }
}

#Preview("") {
    CriticalErrorView(
        message: "Some critical error occured!"
    )
}
