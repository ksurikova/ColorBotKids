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
                NSLocalizedString("common_message_volumeMuted", comment: "VolumeWarningLevel")
            )
        case .veryLow:
            return (
                "speaker.wave.1.fill",
                NSLocalizedString("common_message_volumeVeryLow", comment: "VolumeWarningLevel")
            )
        case .low:
            return (
                "speaker.wave.2.fill",
                NSLocalizedString("common_message_volumeLow", comment: "VolumeWarningLevel")
            )
        }
    }
}
