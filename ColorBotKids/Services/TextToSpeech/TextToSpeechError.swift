//
//  TextToSpeechError.swift
//  ColorBotKids
//
//  Created by  ksurikova on 5.12.2025.
//
import Foundation

enum TextToSpeechError: LocalizedError {
    case unsupportedSettings
    case initializationFailed(Error)
    case audioSessionFailed(Error)
    case volumeTooLow
    case speechFailed

    var errorDescription: String? {
        switch self {
        case .unsupportedSettings:
            return NSLocalizedString(
                "text_to_speech_error_unsupportedSettings",
                comment: "TextToSpeechError"
            )
        case let .initializationFailed(error):
            let format = NSLocalizedString(
                "text_to_speech_error_initializationFailed",
                comment: "TextToSpeechError"
            )
            return String(format: format, error.localizedDescription)
        case let .audioSessionFailed(error):
            let format = NSLocalizedString(
                "text_to_speech_error_audioSessionFailed",
                comment: "TextToSpeechError"
            )
            return String(format: format, error.localizedDescription)
        case .volumeTooLow:
            return NSLocalizedString(
                "text_to_speech_error_volumeTooLow",
                comment: "TextToSpeechError"
            )
        case .speechFailed:
            return NSLocalizedString(
                "text_to_speech_error_speechFailed",
                comment: "TextToSpeechError"
            )
        }
    }
}
