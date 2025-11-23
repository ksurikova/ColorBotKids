//
//  PermissionBadgeStyle.swift
//  ColorBotKids
//
//  Created by ksurikova on 8.11.2025.
//
import SwiftUI

struct PermissionBadgeStyle: ViewModifier {
    let isRequired: Bool

    func body(content: Content) -> some View {
        content
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isRequired ? Color.red.opacity(0.15) : Color.gray.opacity(0.15))
            )
            .foregroundColor(isRequired ? .red : .secondary)
    }
}

extension View {
    func permissionBadge(isRequired: Bool) -> some View {
        modifier(PermissionBadgeStyle(isRequired: isRequired))
    }
}
