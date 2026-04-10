//
//  SpeechCapabilities.swift
//  ColorBotKids
//
//  Created by ksurikova on 10.04.2026.
//
import Foundation

struct SpeechCapabilities: Equatable {
    let locale: Locale
    let speechAvailable: Bool
    let onDeviceAvailable: Bool
    let ttsAvailable: Bool

    // Whether the minimum required capabilities for speech recognition are met.
    var isCriticalValid: Bool {
        speechAvailable
    }
}
