//
//  TextToSpeechSettings.swift
//  ColorBotKids
//
//  Created by ksurikova on 31.10.2025.
//
import Foundation

struct TextToSpeechSettings {
    let locale: Locale

    init(
        locale: Locale = Locale(identifier: "en-US")
    ) {
        self.locale = locale
    }
}
