//
//  MockSettingsService.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.12.2025.
//

struct MockSettingsService: SettingsService {
    func openAppSettings(
        willOpen: (() -> Void)?,
        completion: ((Bool) -> Void)?
    ) {
        print("Attempting to open app settings.")
        willOpen?()
        completion?(true)
    }
}
