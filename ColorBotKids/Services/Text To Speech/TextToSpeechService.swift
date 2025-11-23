//
//  TextToSpeechService.swift
//  ColorBotKids
//
//  Created by ksurikova on 31.10.2025.
//
import Foundation
import SwiftUI

protocol TextToSpeechService {
    init(settings: TextToSpeechSettings)
    func speak(_ text: String)
    func stop()
    var isSpeaking: Bool { get }
    var isAvailable: Bool { get }
    var onVolumeWarning: (() -> Void)? { get set }
    var onDidFailToPlay: (() -> Void)? { get set }
    var onStartSpeaking: (() -> Void)? { get set }
    static func isAvailableWithCurrentSettings(_ settings: TextToSpeechSettings) -> Bool
}

enum TextToSpeechError: LocalizedError {
    case unsupportedSettings
    case initializationFailed(Error)
    case audioSessionFailed(Error)
    case volumeTooLow
    case speechFailed

    var errorDescription: String? {
        switch self {
        case .unsupportedSettings:
            return "The selected text to speech configuration is not supported."
        case let .initializationFailed(error):
            return "Failed to initialize text to speech service: \(error.localizedDescription)"
        case let .audioSessionFailed(error):
            return "Audio playback error: \(error.localizedDescription)"
        case .volumeTooLow:
            return "Volume is too low. Please turn up your device volume."
        case .speechFailed:
            return "Failed to play speech. Please try again."
        }
    }
}

private struct TextToSpeechServiceTypeKey: EnvironmentKey {
    static let defaultValue: TextToSpeechService.Type = MockTextToSpeechService.self
}

extension EnvironmentValues {
    var textToSpeechServiceType: TextToSpeechService.Type {
        get { self[TextToSpeechServiceTypeKey.self] }
        set { self[TextToSpeechServiceTypeKey.self] = newValue }
    }
}

private struct TextToSpeechServiceKey: EnvironmentKey {
    static let defaultValue: TextToSpeechService = MockTextToSpeechService(
        settings: TextToSpeechSettings(
            locale: Locale(identifier: "en-US")))
}

extension EnvironmentValues {
    var textToSpeechService: TextToSpeechService {
        get { self[TextToSpeechServiceKey.self] }
        set { self[TextToSpeechServiceKey.self] = newValue }
    }
}
