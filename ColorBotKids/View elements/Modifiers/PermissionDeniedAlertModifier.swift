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
        permissionInfo.titleKey
    }

    func body(content: Content) -> some View {
        content
            .alert("common_errorTitle_permissionDenied", isPresented: $isPresented) {
                Button("common_action_openSettings") {
                    onOpenSettings()
                }
                Button("common_action_cancel", role: .cancel) {}
            } message: {
                Text(String(
                    format: NSLocalizedString("common_errorMessage_permissionDenied", comment: ""),
                    localizedTitle,
                    localizedTitle
                ))
            }
    }
}
