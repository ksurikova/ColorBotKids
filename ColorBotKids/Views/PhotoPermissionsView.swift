//
//  PhotoPermissionsView.swift
//  ColorBotKids
//
//  Created by ksurikova on 7.11.2025.
//
import SwiftUI

struct PhotoPermissionsView: View {
    @Environment(\.permissionService) private var permissionService
    @Binding var photoLibraryStatus: PermissionStatus

    var body: some View {
        VStack(spacing: 24) {
            DefaultIcon(
                name: "photo.on.rectangle.angled",
                foregroundStyle: AnyShapeStyle(LinearGradient.bluePurple)
            )

            Text("Photo Library Access").mainStyle()

            Text(
                "To save your generated or colored images, please allow access to your Photo Library."
            )
            .plainStyle()
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)

            VStack(spacing: 16) {
                PermissionRow(
                    permissionInfo: Permissions.photoLibrary,
                    status: $photoLibraryStatus,
                    permissionService: permissionService
                )
            }

            Spacer()
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .padding()
    }
}

#Preview {
    PhotoPermissionsView(photoLibraryStatus: Binding.constant(.notDetermined)).environment(
        \.permissionService,
        MockPermissionService()
    )
}
