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
    var onVolumeWarning: ((VolumeWarningLevel) -> Void)? { get set }
    var onDidFailToPlay: (() -> Void)? { get set }
    var onStartSpeaking: (() -> Void)? { get set }
    static func isAvailableWithCurrentSettings(_ settings: TextToSpeechSettings) -> Bool
}

extension TextToSpeechService {
    func speakSafely(_ text: String) {
        if isSpeaking {
            stop()
        }
        speak(text)
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
            locale: Locale(identifier: AppConstants.defaultLocaleIdentifier)))
}

extension EnvironmentValues {
    var textToSpeechService: TextToSpeechService {
        get { self[TextToSpeechServiceKey.self] }
        set { self[TextToSpeechServiceKey.self] = newValue }
    }
}
