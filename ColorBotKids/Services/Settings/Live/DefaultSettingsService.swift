//
//  DefaultSettingsService.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.12.2025.
//
import Foundation
import UIKit

class DefaultSettingsService: SettingsService {
    func openAppSettings(
        willOpen: (() -> Void)? = nil,
        completion: ((_ success: Bool) -> Void)? = nil
    ) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            completion?(false)
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            willOpen?() // Execute the callback before opening the URL
            UIApplication.shared.open(url, options: [:]) { success in
                completion?(success)
            }
        } else {
            completion?(false)
        }
    }
}
