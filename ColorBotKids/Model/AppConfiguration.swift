//
//  AppConfiguration.swift
//  ColorBotKids
//
//  Created by ksurikova on 17.10.2025.
//
struct AppConfiguration: Codable, Equatable {
    var aiConfig: AIConfiguration?
    var speechConfig: SpeechConfiguration?

    var isAIConfigured: Bool {
        aiConfig != nil
    }

    var isSpeechConfigured: Bool {
        speechConfig != nil
    }

    var isFullyConfigured: Bool {
        isAIConfigured && isSpeechConfigured
    }

    mutating func reset() {
        aiConfig = nil
        speechConfig = nil
    }
}
