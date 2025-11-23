//
//  SpeechConfiguration.swift
//  ColorBotKids
//
//  Created by ksurikova on 17.10.2025.
//
import Foundation

struct SpeechConfiguration: Codable, Equatable {
    let language: String
    let useOnlyOnDevice: Bool
    let autoPlayConfirmation: Bool

    init(language: String, useOnlyOnDevice: Bool, autoPlayConfirmation: Bool) {
        // Always store normalized identifiers
        self.language = Locale.normalize(language)
        self.useOnlyOnDevice = useOnlyOnDevice
        self.autoPlayConfirmation = autoPlayConfirmation
    }
}
