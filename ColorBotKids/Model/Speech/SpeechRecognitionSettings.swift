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

    init(
        locale: Locale = Locale(identifier: "en-US"),
        requiresOnDevice: Bool = false
    ) {
        self.locale = locale
        self.requiresOnDevice = requiresOnDevice
        shouldReportPartialResults = true
    }
}
