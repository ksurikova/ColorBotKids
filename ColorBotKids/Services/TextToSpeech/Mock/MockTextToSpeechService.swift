//
//  MockTextToSpeechService.swift
//  ColorBotKids
//
//  Created by ksurikova on 31.10.2025.
//
import Foundation

final class MockTextToSpeechService: TextToSpeechService {
    static var isAvailableOverride: Bool?

    // MARK: - Static configuration for tests or previews

    static func configure(isAvailable: Bool? = nil) {
        if let isAvailable = isAvailable {
            isAvailableOverride = isAvailable
        }
    }

    static func reset() {
        isAvailableOverride = nil
    }

    var onDidFailToPlay: (() -> Void)?
    var onStartSpeaking: (() -> Void)?
    var onVolumeWarning: ((VolumeWarningLevel) -> Void)?
    var isSpeaking: Bool = false
    var spokenTexts: [String] = []
    var isAvailable: Bool = true

    init(settings: TextToSpeechSettings) {
        // do nothing
        print("MockTextToSpeechService: we are inside test init ")
    }

    static func isAvailableWithCurrentSettings(_ settings: TextToSpeechSettings) -> Bool {
        if let override = isAvailableOverride {
            return override
        }
        return true
    }

    func speak(_ text: String) {
        spokenTexts.append(text)
        isSpeaking = true
        onStartSpeaking?()

        // Simulate completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isSpeaking = false
        }
    }

    func stop() {
        isSpeaking = false
    }

    // Test helpers
    func simulateVolumeWarning() {
        onVolumeWarning?(VolumeWarningLevel.low)
    }

    func simulateFailure() {
        onDidFailToPlay?()
    }
}
