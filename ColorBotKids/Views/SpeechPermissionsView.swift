//
//  SpeechPermissionsView.swift
//  ColorBotKids
//
//  Created by ksurikova on 24.10.2025.
//
import SwiftUI

struct SpeechPermissionsView: View {
    @Environment(\.permissionService) private var permissionService
    @Binding var microphoneStatus: PermissionStatus
    @Binding var speechRecognitionStatus: PermissionStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Permissions")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .padding(.horizontal, 4)
            Text("We need these permissions to enable voice recognition")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
                .padding(.bottom, 4)
            VStack(spacing: 12) {
                PermissionRow(
                    permissionInfo: Permissions.microphone,
                    status: $microphoneStatus,
                    permissionService: permissionService
                )

                PermissionRow(
                    permissionInfo: Permissions.speechRecognition,
                    status: $speechRecognitionStatus,
                    permissionService: permissionService
                )
            }
        }
    }
}

#Preview {
    SpeechPermissionsView(
        microphoneStatus: Binding.constant(.notDetermined),
        speechRecognitionStatus: Binding.constant(.notDetermined)
    )
    .environment(\.permissionService, MockPermissionService())
}
