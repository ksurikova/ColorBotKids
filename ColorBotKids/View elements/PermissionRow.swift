//
//  PermissionRow.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.11.2025.
//
import SwiftUI

struct PermissionRow<P: PermissionViewRepresentable>: View {
    let permissionInfo: P
    @Binding var status: PermissionStatus
    let permissionService: PermissionService

    @State private var isProcessing = false
    @State private var showRestrictedAlert = false
    @State private var showDeniedAlert = false

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: permissionInfo.icon)
                .font(.system(size: 32))
                .foregroundStyle(
                    LinearGradient(
                        colors: statusColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44)

            // Text content
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(permissionInfo.title)
                        .permissionTitle()

                    Text(permissionInfo.isRequired ? "Required" : "Optional")
                        .permissionBadge(isRequired: permissionInfo.isRequired)
                }

                Text(permissionInfo.description)
                    .permissionDescription()
            }

            Spacer()

            // Action button or status icon
            if status.isAuthorized {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            } else {
                PermissionActionButton(
                    status: status,
                    isProcessing: $isProcessing,
                    onRequestPermission: {
                        await requestPermission()
                    },
                    onShowDeniedAlert: {
                        showDeniedAlert = true
                    },
                    onShowRestrictedAlert: {
                        showRestrictedAlert = true
                    }
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemGray6))
        )
        .permissionDeniedAlert(
            permissionInfo: permissionInfo,
            isPresented: $showDeniedAlert,
            onOpenSettings: { openAppSettings() }
        )
        .permissionRestrictedAlert(
            isPresented: $showRestrictedAlert,
            onOpenSettings: { openSettings() }
        )
    }

    private var statusColors: [Color] {
        switch status {
        case .authorized:
            return [.green, .green.opacity(0.7)]
        case .notDetermined:
            return [.blue, .blue.opacity(0.7)]
        case .denied:
            return [.orange, .orange.opacity(0.7)]
        case .restricted:
            return [.red, .red.opacity(0.7)]
        }
    }

    private func requestPermission() async {
        isProcessing = true
        defer { isProcessing = false }
        let granted = await permissionService.grantPermission(for: permissionInfo)
        if granted {
            status = .authorized
        } else {
            status = permissionService.checkPermission(for: permissionInfo)
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

    private func openSettings() {
        // right now we do the same thing as openAppSettings, but may be in future the situation
        // will be changed
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Preview

#Preview("All States") {
    VStack(spacing: 16) {
        PermissionRow(
            permissionInfo: Permissions.microphone,
            status: Binding.constant(.notDetermined),
            permissionService: MockPermissionService()
        )

        PermissionRow(
            permissionInfo: Permissions.speechRecognition,
            status: Binding.constant(.denied),
            permissionService: MockPermissionService()
        )

        PermissionRow(
            permissionInfo: Permissions.photoLibrary,
            status: Binding.constant(.authorized),
            permissionService: MockPermissionService()
        )

        PermissionRow(
            permissionInfo: Permissions.microphone,
            status: Binding.constant(.restricted),
            permissionService: MockPermissionService()
        )
    }
    .padding()
}
