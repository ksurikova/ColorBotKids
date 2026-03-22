import SwiftUI

struct PermissionRow<P: PermissionViewRepresentable>: View {
    let permissionInfo: P
    let status: PermissionStatus

    let onRequestPermission: (any PermissionDefinition) async -> Bool

    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var isProcessing = false
    @State private var showRestrictedAlert = false
    @State private var showDeniedAlert = false

    var body: some View {
        Group {
            if sizeClass == .compact {
                compactLayout
            } else {
                regularLayout
            }
        }
        .padding(12)
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

    private var regularLayout: some View {
        HStack(spacing: 16) {
            iconView

            // Text content
            VStack(alignment: .leading, spacing: 6) {
                titleRow
                descriptionView
            }

            Spacer()

            // Action button or status icon
            if status.isAuthorized {
                authorizedIndicator
            } else {
                actionButton
            }
        }
    }

    private var compactLayout: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                iconView
                titleRow
                Spacer()
                if status.isAuthorized {
                    authorizedIndicator
                }
            }

            descriptionView

            if !status.isAuthorized {
                actionButton
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var iconView: some View {
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
    }

    private var titleRow: some View {
        HStack(spacing: 8) {
            Text(permissionInfo.title)
                .permissionTitle()
            Spacer()
            Text(permissionInfo
                .isRequired ? "common_title_required" : "common_title_optional")
                .permissionBadge(isRequired: permissionInfo.isRequired)
        }
    }

    private var descriptionView: some View {
        Text(permissionInfo.description)
            .permissionDescription()
            .fixedSize(horizontal: false, vertical: true)
    }

    private var authorizedIndicator: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 28))
            .foregroundStyle(
                LinearGradient(
                    colors: [.green, .green.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var actionButton: some View {
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

#Preview {
    VStack(spacing: 20) {
        PermissionRow(
            permissionInfo: MicrophonePermission.shared,
            status: .notDetermined,
            onRequestPermission: { _ in
                try? await Task.sleep(for: .seconds(1))
                return true
            }
        )

        PermissionRow(
            permissionInfo: SpeechRecognitionPermission.shared,
            status: .authorized,
            onRequestPermission: { _ in true }
        )

        PermissionRow(
            permissionInfo: PhotoLibraryPermission.shared,
            status: .denied,
            onRequestPermission: { _ in false }
        )

        PermissionRow(
            permissionInfo: PhotoLibraryPermission.shared,
            status: .restricted,
            onRequestPermission: { _ in false }
        )
    }
    .padding()
    .background(Color(.systemBackground))
}
