//
//  TextToSpeechSettings.swift
//  ColorBotKids
//
//  Created by ksurikova on 05.12.2025.
//

import Foundation

struct TextToSpeechSettings {
    let locale: Locale
    init(
        locale: Locale = Locale(identifier: AppConstants.defaultLocaleIdentifier)
    ) {
        self.locale = locale
    }
}
