//
//  SpeechRecognitionService.swift
//  ColorBotKids
//
//  Created by ksurikova on 23.10.2025.
//
import Foundation
import Speech
import SwiftUI

struct SpeechRecognitionSettings {
    var locale: Locale
    var requiresOnDevice: Bool
    var shouldReportPartialResults: Bool

    init(
        locale: Locale = Locale(identifier: "en-US"),
        requiresOnDevice: Bool = false,
        shouldReportPartialResults: Bool = true
    ) {
        self.locale = locale
        self.requiresOnDevice = requiresOnDevice
        self.shouldReportPartialResults = shouldReportPartialResults
    }
}

protocol SpeechRecognitionService {
    var isRunning: Bool { get }
    init(settings: SpeechRecognitionSettings) throws
    func startRecognition() async throws
    func stopRecognition() async throws -> String
    static func getSupportedLocales() -> [Locale]
    static func canCreateWithCurrentSettings(_ settings: SpeechRecognitionSettings) -> Bool
}

enum SpeechRecognitionError: LocalizedError {
    case notAuthorized
    case recognizerUnavailable
    case recognizerNotSupported
    case audioConversionFailed
    case recognitionFailed(Error)
    case noResultsReturned
    case alreadyRunning
    case notRunning
    case unsupportedSettings
    case initializationFailed(Error)

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Speech recognition is not authorized. Please enable it in Settings."
        case .recognizerUnavailable:
            return "Speech recognizer is currently unavailable. Please try again later."
        case .recognizerNotSupported:
            return "Speech recognition is not supported for the selected language."
        case .audioConversionFailed:
            return "Failed to convert audio data for recognition."
        case let .recognitionFailed(error):
            return "Speech recognition failed: \(error.localizedDescription)"
        case .noResultsReturned:
            return "No speech was recognized in the audio."
        case .alreadyRunning:
            return "Recognition is already running."
        case .notRunning:
            return "Recognition is not currently running."
        case .unsupportedSettings:
            return "The selected speech configuration is not supported."
        case let .initializationFailed(error):
            return "Failed to initialize speech recognition service: \(error.localizedDescription)"
        }
    }
}

private struct SpeechRecognitonServiceKey: EnvironmentKey {
    static let defaultValue: SpeechRecognitionService = {
        do {
            return try MockSpeechRecognitionService(
                settings: SpeechRecognitionSettings(
                    locale: Locale(identifier: "en-US"),
                    requiresOnDevice: true
                )
            )
        } catch {
            fatalError("Failed to initialize default SpeechRecognitionService: \(error)")
        }
    }()
}

extension EnvironmentValues {
    var speechRecognitionService: SpeechRecognitionService {
        get { self[SpeechRecognitonServiceKey.self] }
        set { self[SpeechRecognitonServiceKey.self] = newValue }
    }
}

private struct SpeechServiceTypeKey: EnvironmentKey {
    static let defaultValue: SpeechRecognitionService.Type = MockSpeechRecognitionService.self
}

extension EnvironmentValues {
    var speechServiceType: SpeechRecognitionService.Type {
        get { self[SpeechServiceTypeKey.self] }
        set { self[SpeechServiceTypeKey.self] = newValue }
    }
}
