//
//  PhotoPermissionsView.swift
//  ColorBotKids
//
//  Created by ksurikova on 7.11.2025.
//
import SwiftUI

struct PhotoPermissionsView: View {
    @StateObject private var viewModel: PhotoLibraryViewModel

    init(viewModel: PhotoLibraryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 24) {
            OnboardingHeaderView(
                icon: "photo.on.rectangle.angled",
                title: "onboarding_title_photoPermissions",
                description: "onboarding_description_photoPermissions"
            )

            PermissionRow(
                permissionInfo: Permissions.photoLibrary,
                status: viewModel.status, // Reactive property
                onRequestPermission: { _ in await viewModel.request() }
            )

            Spacer()
        }
        .padding()
    }
}

// #Preview {
//    let permissionManager = PermissionManager(service: DefaultPermissionService())
//
//    PhotoPermissionsView(permissionManager: permissionManager)
// }
