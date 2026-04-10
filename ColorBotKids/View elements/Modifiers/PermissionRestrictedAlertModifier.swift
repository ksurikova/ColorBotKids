//
//  PermissionRestrictedAlertModifier.swift
//  ColorBotKids
//
//  Created by ksurikova on 8.11.2025.
//
import SwiftUI

struct PermissionRestrictedAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let onOpenSettings: () -> Void

    func body(content: Content) -> some View {
        content
            .alert(
                String(localized: "common_errorTitle_permissionRestricted"),
                isPresented: $isPresented
            ) {
                Button(String(localized: "common_action_openSettings")) {
                    onOpenSettings()
                }
                Button(String(localized: "common_action_cancel"), role: .cancel) {}
            } message: {
                Text(String(localized: "common_errorMessage_permissionRestricted"))
            }
    }
}
