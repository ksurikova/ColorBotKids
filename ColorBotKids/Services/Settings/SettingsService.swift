//
//  SettingsService.swift
//  ColorBotKids
//
//  Created by ksurikova on 25.11.2025.
//
import SwiftUI

protocol SettingsService {
    func openAppSettings(
        willOpen: (() -> Void)?,
        completion: ((_ success: Bool) -> Void)?
    )
}

// Environment Key for dependency injection
private struct SettingsServiceKey: EnvironmentKey {
    static let defaultValue: SettingsService = DefaultSettingsService()
}

extension EnvironmentValues {
    var settingsService: SettingsService {
        get { self[SettingsServiceKey.self] }
        set { self[SettingsServiceKey.self] = newValue }
    }
}
