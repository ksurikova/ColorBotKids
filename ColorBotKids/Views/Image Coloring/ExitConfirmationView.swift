//
//  ExitConfirmationView.swift
//  ColorBotKids
//
//  Created by ksurikova on 13.11.2025.
//
import SwiftUI

struct ExitConfirmationView: View {
    let onSaveAndExit: () -> Void
    let onExitWithoutSaving: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.orange)
            }
            .padding(.top, 24)

            Text("Save your drawing?")
                .confirmationTitle()

            Text("You made something awesome! Want to keep it?")
                .confirmationDescription()

            Spacer()

            ConfirmationButtons(
                onSave: onSaveAndExit,
                onCancelSave: onExitWithoutSaving,
                onContinue: onCancel
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .background(Color(.systemBackground))
    }
}

#Preview("Unsaved changes") {
    ExitConfirmationView(
        onSaveAndExit: {},
        onExitWithoutSaving: {},
        onCancel: {}
    )
}
