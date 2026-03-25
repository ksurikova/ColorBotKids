//
//  MainActionState.swift
//  ColorBotKids
//
//  Created by ksurikova on 25.10.2025.
//

enum MainActionState: Equatable {
    case preparingServices // App is building the engines
    case waiting // Ready for user input
    case processingSpeech // Recording audio
    case analysingSpeech // Waiting for transcription

    // Success flow
    case speechRecognized(String) // Text ready to display
    case generatingImage(from: String) // Hitting the AI API

    // Error flow - carrying the prompt ensures the UI doesn't flicker to empty
    case temporaryError(String, prompt: String?)

    // Specific state for Auth issues that blocks the main button but enables Settings
    case configurationRequired(String, prompt: String?)
    case fatalError(AppError)

    var isProcessing: Bool {
        switch self {
        case .processingSpeech, .analysingSpeech:
            return true
        default:
            return false
        }
    }

    var isSpeechRecognized: Bool {
        if case .speechRecognized = self {
            return true
        }
        return false
    }

    var canToggleRecognition: Bool {
        switch self {
        // Allow recording to restart from error states
        case .waiting, .processingSpeech, .speechRecognized, .temporaryError:
            return true
        default:
            return false
        }
    }

    var errorMessage: String? {
        switch self {
        case let .temporaryError(message, _):
            return message
        default:
            return nil
        }
    }

    var configurationRequiredMessage: String? {
        switch self {
        case let .configurationRequired(message, _):
            return message
        default:
            return nil
        }
    }

    var recognizedText: String? {
        switch self {
        case let .speechRecognized(text), let .generatingImage(from: text):
            return text
        // If an image generation failed, we still want to see what prompt failed
        case let .temporaryError(_, prompt), let .configurationRequired(_, prompt):
            return prompt
        default:
            return nil
        }
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
