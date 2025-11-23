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

    func body(content: Content) -> some View {
        content
            .alert("Permission Denied", isPresented: $isPresented) {
                Button("Open Settings") {
                    onOpenSettings()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("""
                You previously denied \(permissionInfo.title) access.

                To enable it:
                1. Open Settings (tap button below)
                2. Find this app in the list
                3. Tap on \(permissionInfo.title)
                4. Enable access
                """)
            }
    }
}
