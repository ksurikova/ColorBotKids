//
//  MockSpeechRecognitonService.swift
//  ColorBotKids
//
//  Created by ksurikova on 23.10.2025.
//
import Foundation

final class MockSpeechRecognitionService: SpeechRecognitionService {
    func getCurrentLocale() -> Locale {
        Locale(identifier: "en-US")
    }

    static func canRunApp() -> Bool {
        true
    }

    static func unavailabilityMessage() -> String? {
        nil
    }

    var isRunning: Bool = false

    private var canCreateWithSettings = false

    init(settings: SpeechRecognitionSettings) throws {
        // fake init
    }

    // MARK: - Static configuration for tests or previews

    static var supportedLocales: [Locale] = [
        Locale(identifier: "en-US"),
        Locale(identifier: "fr-FR"),
    ]

    static var canCreateWithCurrentSettingsResponse: Bool = false

    func startRecognition() throws {
        // do nothing
    }

    func stopRecognition() async throws -> String {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return "tree"
    }

    static func getSupportedLocales() -> [Locale] {
        supportedLocales
    }

    static func canCreateWithCurrentSettings(_ settings: SpeechRecognitionSettings) -> Bool {
        canCreateWithCurrentSettingsResponse
    }
}
