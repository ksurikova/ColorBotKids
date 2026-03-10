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
            .alert("common_errorTitle_permissionRestricted", isPresented: $isPresented) {
                Button("common_action_openSettings") {
                    onOpenSettings()
                }
                Button("common_action_cancel", role: .cancel) {}
            } message: {
                Text("common_errorMessage_permissionRestricted")
            }
    }
}
