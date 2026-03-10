import SwiftUI

struct PermissionRow<P: PermissionViewRepresentable>: View {
    let permissionInfo: P
    let status: PermissionStatus

    let onRequestPermission: (any PermissionDefinition) async -> Bool

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
                    Text(permissionInfo
                        .isRequired ? "common_title_required" : "common_title_optional")
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
            onOpenSettings: openSettings
        )
        .permissionRestrictedAlert(
            isPresented: $showRestrictedAlert,
            onOpenSettings: openSettings
        )
    }

    private var statusColors: [Color] {
        switch status {
        case .notDetermined:
            return [.gray, .gray.opacity(0.7)]
        case .denied:
            return [.red, .red.opacity(0.7)]
        case .authorized:
            return [.green, .green.opacity(0.7)]
        case .restricted:
            return [.orange, .orange.opacity(0.7)]
        }
    }

    private func requestPermission() async {
        isProcessing = true
        // for test
        // try? await Task.sleep(for: .seconds(1.0))
        _ = await onRequestPermission(permissionInfo)
        isProcessing = false
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
