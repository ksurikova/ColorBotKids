//
//  PermissionService.swift
//  ColorBotKids
//
//  Created by ksurikova on 4.11.2025.
//
protocol PermissionService {
    func checkPermission(for type: any PermissionDefinition) -> PermissionStatus
    func grantPermission(for type: any PermissionDefinition) async -> Bool
}
