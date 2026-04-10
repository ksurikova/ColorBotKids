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
    case recognitionFailed
    case noResultsReturned
    case alreadyRunning
    case notRunning
    case cancelled
    case timeout
    case initializationFailed

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return String(localized: "speech_recognition_error_notAuthorized")
        case .recognizerUnavailable:
            return String(localized: "speech_recognition_error_recognizerUnavailable")
        case .recognitionFailed:
            return String(localized: "speech_recognition_error_recognitionFailed")
        case .noResultsReturned:
            return String(localized: "speech_recognition_error_noResultsReturned")
        case .alreadyRunning:
            return String(localized: "speech_recognition_error_alreadyRunning")
        case .notRunning:
            return String(localized: "speech_recognition_error_notRunning")
        case .cancelled:
            return String(localized: "speech_recognition_error_cancelled")
        case .timeout:
            return String(localized: "speech_recognition_error_timeout")
        case .initializationFailed:
            return String(localized: "speech_recognition_error_initializationFailed")
        }
    }

//        var recoverySuggestion: String? {
//            switch self {
//            case .notAuthorized:
//                return "Go to Settings > Privacy > Microphone and enable access for this app."
//            case .recognizerUnavailable:
//                return "Check your internet connection or try again later."
//            case .recognitionFailed:
//                return "Try speaking again. If the problem persists, restart the app."
//            case .noResultsReturned:
//                return "Try speaking clearly and closer to the microphone."
//            case .alreadyRunning, .notRunning, .cancelled:
//                return nil
//            case .timeout:
//                return "Try speaking sooner after starting recognition."
//            case .initializationFailed:
//                return "Try a different language in Settings, or enable on-device recognition."
//            }
//        }

//        var failureReason: String? {
//            switch self {
//            case .notAuthorized:
//                return "The app does not have permission to access the microphone or speech
//                recognition."
//            case .recognizerUnavailable:
//                return "The speech recognizer became unavailable during the session."
//            case .recognitionFailed:
//                return "The speech recognizer returned an error while processing audio."
//            case .noResultsReturned:
//                return "The recognizer completed but produced an empty transcription."
//            case .alreadyRunning:
//                return "A recognition session is already active."
//            case .notRunning:
//                return "No recognition session is currently active."
//            case .cancelled:
//                return "The session was cancelled before a result was produced."
//            case .timeout:
//                return "The recognizer did not return a final result within the allowed time."
//            case .initializationFailed:
//                return "The SFSpeechRecognizer could not be created for the requested locale or
//                on-device mode."
//            }
//        }
}
