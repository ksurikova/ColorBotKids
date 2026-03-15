//
//  SpeechRecognitionError.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.12.2025.
//
import Foundation

enum SpeechRecognitionError: LocalizedError {
    case notAuthorized
    case recognizerUnavailable
    case recognizerNotSupported
    case audioConversionFailed
    case recognitionFailed(Error)
    case noResultsReturned
    case alreadyRunning
    case notRunning
    case cancelled
    case unsupportedSettings
    case initializationFailed(Error)

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return NSLocalizedString(
                "speech_recognition_error_notAuthorized",
                comment: "SpeechRecognitionError"
            )
        case .recognizerUnavailable:
            return NSLocalizedString(
                "speech_recognition_error_recognizerUnavailable",
                comment: "SpeechRecognitionError"
            )
        case .recognizerNotSupported:
            return NSLocalizedString(
                "speech_recognition_error_recognizerNotSupported",
                comment: "SpeechRecognitionError"
            )
        case .audioConversionFailed:
            return NSLocalizedString(
                "speech_recognition_error_audioConversionFailed",
                comment: "SpeechRecognitionError"
            )
        case let .recognitionFailed(error):
            let format = NSLocalizedString(
                "speech_recognition_error_recognitionFailed",
                comment: "SpeechRecognitionError"
            )
            return String(format: format, error.localizedDescription)
        case .noResultsReturned:
            return NSLocalizedString(
                "speech_recognition_error_noResultsReturned",
                comment: "SpeechRecognitionError"
            )
        case .alreadyRunning:
            return NSLocalizedString(
                "speech_recognition_error_alreadyRunning",
                comment: "SpeechRecognitionError"
            )
        case .notRunning:
            return NSLocalizedString(
                "speech_recognition_error_notRunning",
                comment: "SpeechRecognitionError"
            )
        case .cancelled:
            return NSLocalizedString(
                "speech_recognition_error_cancelled",
                comment: "SpeechRecognitionError"
            )
        case .unsupportedSettings:
            return NSLocalizedString(
                "speech_recognition_error_unsupportedSettings",
                comment: "SpeechRecognitionError"
            )
        case let .initializationFailed(error):
            let format = NSLocalizedString(
                "speech_recognition_error_initializationFailed",
                comment: "SpeechRecognitionError"
            )
            return String(format: format, error.localizedDescription)
        }
    }
}
