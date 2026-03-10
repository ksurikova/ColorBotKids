//
//  SpeechPermissionsView.swift
//  ColorBotKids
//
//  Created by ksurikova on 24.10.2025.
//
import Combine
import SwiftUI

struct SpeechPermissionsSection: View {
    @StateObject private var viewModel: SpeechPermissionsViewModel

    init(permissionManager: PermissionManager) {
        // because we have lightweighted ViewModel, we can create it directly in init without
        // worrying about performance
        _viewModel =
            StateObject(wrappedValue: SpeechPermissionsViewModel(manager: permissionManager))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("onboarding_title_permissions")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .padding(.horizontal, 4)
            Text("onboarding_description_permissions")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
                .padding(.bottom, 4)
            VStack(spacing: 12) {
                PermissionRow(
                    permissionInfo: Permissions.microphone,
                    status: viewModel.micStatus,
                    onRequestPermission: viewModel.request
                )

                PermissionRow(
                    permissionInfo: Permissions.speechRecognition,
                    status: viewModel.speechStatus,
                    onRequestPermission: viewModel.request
                )
            }
        }
    }
}
