//
//  PermissionActionButton.swift
//  ColorBotKids
//
//  Created by ksurikova on 8.11.2025.
//
import SwiftUI

struct PermissionActionButton: View {
    let status: PermissionStatus
    @Binding var isProcessing: Bool
    let onRequestPermission: () async -> Void
    let onShowDeniedAlert: () -> Void
    let onShowRestrictedAlert: () -> Void

    var body: some View {
        if let config = getActionConfig(for: status) {
            if config.subtitle != nil {
                // Standard button with permission action style
                Button(action: {
                    handleAction(config.action)
                }, label: {
                    buttonContent(for: config)
                })
                .buttonStyle(.permissionAction(color: config.color))
                .disabled(isProcessing)
            } else {
                // Custom styled button (for restricted case)
                Button(action: {
                    handleAction(config.action)
                }, label: {
                    buttonContent(for: config)
                })
                .disabled(isProcessing)
            }
        }
    }

    @ViewBuilder
    private func buttonContent(for config: ActionConfig) -> some View {
        if config.action == .request && isProcessing {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .frame(width: 80, height: 40)
        } else if let subtitle = config.subtitle {
            VStack(spacing: 2) {
                Text(subtitle)
                    .font(.caption2)
                    .fontWeight(.semibold)
                Text(config.title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(config.color)
            )
        } else {
            Text(config.title)
        }
    }

    private func handleAction(_ action: ActionType) {
        switch action {
        case .request:
            Task {
                await onRequestPermission()
            }
        case .showDeniedAlert:
            onShowDeniedAlert()
        case .showRestrictedAlert:
            onShowRestrictedAlert()
        }
    }

    func getActionConfig(for status: PermissionStatus) -> ActionConfig? {
        switch status {
        case .notDetermined:
            return ActionConfig(
                title: "Allow",
                color: .blue,
                action: .request
            )
        case .denied:
            return ActionConfig(
                title: "Settings",
                color: .orange,
                action: .showDeniedAlert
            )
        case .restricted:
            return ActionConfig(
                title: "Help",
                color: .red,
                action: .showRestrictedAlert,
                subtitle: "Restricted"
            )
        case .authorized:
            return nil
        }
    }

    enum ActionType {
        case request
        case showDeniedAlert
        case showRestrictedAlert
    }

    struct ActionConfig {
        let title: String
        let color: Color
        let action: ActionType
        var subtitle: String?
    }
}
