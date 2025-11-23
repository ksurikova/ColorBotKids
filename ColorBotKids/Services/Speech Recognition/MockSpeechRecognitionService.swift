//
//  MockSpeechRecognitonService.swift
//  ColorBotKids
//
//  Created by ksurikova on 23.10.2025.
//
import Foundation

final class MockSpeechRecognitionService: SpeechRecognitionService {
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

    func startRecognition() async throws {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }

    func stopRecognition() async throws -> String {
        "tree"
    }

    static func getSupportedLocales() -> [Locale] {
        supportedLocales
    }

    static func canCreateWithCurrentSettings(_ settings: SpeechRecognitionSettings) -> Bool {
        canCreateWithCurrentSettingsResponse
    }
}
