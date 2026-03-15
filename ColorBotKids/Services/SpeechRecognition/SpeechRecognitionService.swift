//
//  SpeechRecognitionService.swift
//  ColorBotKids
//
//  Created by ksurikova on 23.10.2025.
//
import Foundation
import Speech
import SwiftUI

protocol SpeechRecognitionService: CriticalServiceCapability {
    var isRunning: Bool { get }
    init(settings: SpeechRecognitionSettings) throws
    func startRecognition() throws
    func cancelRecognition()
    func stopRecognition() async throws -> String
    static func getSupportedLocales() -> [Locale]
    static func canCreateWithCurrentSettings(_ settings: SpeechRecognitionSettings) -> Bool
    // only to check
    func getCurrentLocale() -> Locale
}

private struct SpeechRecognitonServiceKey: EnvironmentKey {
    static let defaultValue: SpeechRecognitionService = {
        do {
            return try MockSpeechRecognitionService(
                settings: SpeechRecognitionSettings(
                    locale: Locale(identifier: AppConstants.defaultLocaleIdentifier),
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
