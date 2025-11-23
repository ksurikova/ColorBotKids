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
            .alert("Screen Time Restrictions", isPresented: $isPresented) {
                Button("Open Settings") {
                    onOpenSettings()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("""
                This permission is restricted by Screen Time settings.

                To enable it:
                1. Open Settings
                2. Go to Screen Time
                3. Select Content & Privacy Restrictions
                4. Tap on the permission you want to enable
                5. Select "Allow" for this app
                """)
            }
    }
}
