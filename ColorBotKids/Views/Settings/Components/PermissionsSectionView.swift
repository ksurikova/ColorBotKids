//
//  PermissionsSectionView.swift
//  ColorBotKids
//
//  Created by ksurikova on 8.12.2025.
//
import SwiftUI

struct PermissionsPhotoSectionView: View {
    @StateObject private var viewModel: PhotoLibraryViewModel

    init(permissionManager: PermissionManager) {
        _viewModel = StateObject(wrappedValue: PhotoLibraryViewModel(manager: permissionManager))
    }

    var body: some View {
        Section(
            header: Text("settings_title_photoPermissions"),
            footer: Text("settings_description_photoPermissions")
        ) {
            PermissionRow(
                permissionInfo: Permissions.photoLibrary,
                status: viewModel.status,
                onRequestPermission: { _ in await viewModel.request() }
            )
        }
    }
}
