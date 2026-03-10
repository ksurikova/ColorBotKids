//
//  RecognitionState.swift
//  ColorBotKids
//
//  Created by ksurikova on 25.10.2025.
//
enum MainActionState: Equatable {
    case preparingServices // App is building the engines
    case waiting // Ready for user input
    case processingSpeech // Recording audio
    case analysingSpeech // Waiting for transcription
    case speechRecognized(String) // Text ready to display
    case generatingImage(from: String) // Hitting the AI API
    case error(String) // Recoverable error (banner)
    case fatalError(AppError) // Non-recoverable (blocks UI)

    // UI helpers
    var isBlocked: Bool {
        switch self {
        case .preparingServices, .fatalError, .analysingSpeech, .generatingImage:
            return true
        default:
            return false
        }
    }

    var isProcessing: Bool {
        switch self {
        case .error, .speechRecognized, .waiting, .generatingImage, .preparingServices, .fatalError:
            return false
        case .processingSpeech, .analysingSpeech:
            return true
        }
    }

    var isSpeechRecognized: Bool {
        if case .speechRecognized = self {
            return true
        }
        return false
    }

    var canToggleRecognition: Bool {
        // You can only record if the app is ready and not currently busy with AI/Analysis
        switch self {
        case .waiting, .processingSpeech, .speechRecognized, .error:
            return true
        default:
            return false
        }
    }

    var errorMessage: String? {
        if case let .error(message) = self {
            return message
        }
        return nil
    }

    var recognizedText: String? {
        if case let .speechRecognized(text) = self { return text }
        if case let .generatingImage(from: text) = self { return text }
        return nil
    }

    var speechText: String? {
        guard case let .speechRecognized(text) = self else { return nil }
        return text
    }

    var fatalAppError: AppError? {
        if case let .fatalError(error) = self { return error }
        return nil
    }
}
