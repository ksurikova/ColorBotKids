//
//  VolumeWarningLevel+Banner.swift
//  ColorBotKids
//
//  Created by ksurikova on 05.12.2025.
//
import Foundation
import SwiftUI

extension VolumeWarningLevel {
    var bannerConfig: (icon: String, message: String) {
        switch self {
        case .muted:
            return (
                "speaker.slash.fill",
                String(localized: "kid_message_volumeMuted")
            )
        case .veryLow:
            return (
                "speaker.wave.1.fill",
                String(localized: "kid_message_volumeVeryLow")
            )
        case .low:
            return (
                "speaker.wave.2.fill",
                String(localized: "kid_message_volumeLow")
            )
        }
    }
}
