//
//  SpeechRecognitionSettings.swift
//  ColorBotKids
//
//  Created by ksurikova on 05.12.2025.
//
import Foundation

struct SpeechRecognitionSettings {
    var locale: Locale
    var requiresOnDevice: Bool
    var shouldReportPartialResults: Bool
    let speechTimeout: TimeInterval

    init(
        locale: Locale = Locale(identifier: "en-US"),
        requiresOnDevice: Bool = false,
        speechTimeout: TimeInterval = Double(AppConstants.defaultSpeechTimeout)
    ) {
        self.locale = locale
        self.requiresOnDevice = requiresOnDevice
        self.speechTimeout = speechTimeout
        shouldReportPartialResults = true
    }
}
