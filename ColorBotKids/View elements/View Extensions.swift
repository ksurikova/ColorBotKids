//
//  View Extensions.swift
//  ColorBotKids
//
//  Created by ksurikova on 8.11.2025.
//
import SwiftUI

extension View {
    func permissionDeniedAlert(
        permissionInfo: any PermissionViewRepresentable,
        isPresented: Binding<Bool>,
        onOpenSettings: @escaping () -> Void
    ) -> some View {
        modifier(PermissionDeniedAlertModifier(
            permissionInfo: permissionInfo,
            isPresented: isPresented,
            onOpenSettings: onOpenSettings
        ))
    }

    func permissionRestrictedAlert(
        isPresented: Binding<Bool>,
        onOpenSettings: @escaping () -> Void
    ) -> some View {
        modifier(PermissionRestrictedAlertModifier(
            isPresented: isPresented,
            onOpenSettings: onOpenSettings
        ))
    }
}
