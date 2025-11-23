//
//  RecognitionState.swift
//  ColorBotKids
//
//  Created by ksurikova on 25.10.2025.
//
enum RecognitionState: Equatable {
    case waiting
    case processingSpeech
    case analysingSpeech
    case speechRecognized(String)
    case error(String)

    var canRecognize: Bool {
        switch self {
        case .processingSpeech, .error, .analysingSpeech:
            return false
        case .waiting, .speechRecognized:
            return true
        }
    }

    var isSpeechRecognized: Bool {
        if case .speechRecognized = self {
            return true
        } else {
            return false
        }
    }

    var canToggleRecognition: Bool {
        switch self {
        case .error, .analysingSpeech:
            return false
        case .waiting, .processingSpeech, .speechRecognized:
            return true
        }
    }

    var recognizedText: String? {
        if case let .speechRecognized(text) = self {
            return text
        }
        return nil
    }

    var errorMessage: String? {
        if case let .error(message) = self {
            return message
        }
        return nil
    }

    var isProcessing: Bool {
        switch self {
        case .error, .speechRecognized, .waiting:
            return false
        case .processingSpeech, .analysingSpeech:
            return true
        }
    }
}
