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
                titleKey: "common_action_allow",
                color: .blue,
                action: .request
            )
        case .denied:
            return ActionConfig(
                titleKey: "common_action_settings",
                color: .orange,
                action: .showDeniedAlert
            )
        case .restricted:
            return ActionConfig(
                titleKey: "common_action_help",
                color: .red,
                action: .showRestrictedAlert,
                subtitleKey: "common_title_restricted"
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
        let titleKey: String
        let color: Color
        let action: ActionType
        var subtitleKey: String?

        var title: LocalizedStringKey { .init(titleKey) }
        var subtitle: LocalizedStringKey? {
            subtitleKey.map { .init($0) }
        }
    }
}

// MARK: - PermissionActionButton Previews

#Preview("Not Determined") {
    PermissionActionButton(
        status: .notDetermined,
        isProcessing: .constant(false),
        onRequestPermission: {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        },
        onShowDeniedAlert: {
            print("Show denied alert")
        },
        onShowRestrictedAlert: {
            print("Show restricted alert")
        }
    )
}

#Preview("Processing") {
    PermissionActionButton(
        status: .notDetermined,
        isProcessing: .constant(true),
        onRequestPermission: {},
        onShowDeniedAlert: {},
        onShowRestrictedAlert: {}
    )
}

#Preview("Denied") {
    PermissionActionButton(
        status: .denied,
        isProcessing: .constant(false),
        onRequestPermission: {},
        onShowDeniedAlert: {
            print("Show denied alert")
        },
        onShowRestrictedAlert: {}
    )
}

#Preview("Restricted") {
    PermissionActionButton(
        status: .restricted,
        isProcessing: .constant(false),
        onRequestPermission: {},
        onShowDeniedAlert: {},
        onShowRestrictedAlert: {
            print("Show restricted alert")
        }
    )
}
