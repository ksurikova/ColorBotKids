//
//  PermissionAlertModifier.swift
//  ColorBotKids
//
//  Created by ksurikova on 8.11.2025.
//
import SwiftUI

struct PermissionDeniedAlertModifier: ViewModifier {
    let permissionInfo: any PermissionViewRepresentable
    @Binding var isPresented: Bool
    let onOpenSettings: () -> Void

    private var localizedTitle: String {
        permissionInfo.title
    }

    func body(content: Content) -> some View {
        content
            .alert(
                String(localized: "common_errorTitle_permissionDenied"),
                isPresented: $isPresented
            ) {
                Button(String(localized: "common_action_openSettings")) {
                    onOpenSettings()
                }
                Button(String(localized: "common_action_cancel"), role: .cancel) {}
            } message: {
                Text(String(
                    format: String(localized: "common_errorMessage_permissionDenied"),
                    localizedTitle,
                    localizedTitle
                ))
            }
    }
}
