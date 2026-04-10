//
//  SpeechCapabilityResolver.swift
//  ColorBotKids
//
//  Created by ksurikova on 9.02.2026.
//

import Foundation

protocol SpeechCapabilityResolving {
    var speechService: SpeechRecognitionService.Type { get }
    var ttsService: TextToSpeechService.Type { get }

    func resolve(for locale: Locale) -> SpeechCapabilities
    func resolve(from config: SpeechConfiguration) -> SpeechCapabilities
    func getCapableLocales() -> [Locale]
    func resolveLocale(locale: Locale?) -> Locale
    func resolveSettings(from config: SpeechConfiguration) -> (
        speech: SpeechRecognitionSettings, tts: TextToSpeechSettings?
    )
}

struct SpeechCapabilityResolver: SpeechCapabilityResolving {
    let speechService: SpeechRecognitionService.Type
    let ttsService: TextToSpeechService.Type

    // MARK: - Resolution Methods

    // Resolves capabilities specifically for a given Locale.
    // Useful when the user is scrolling through languages in the UI.
    func resolve(for locale: Locale) -> SpeechCapabilities {
        let speechAvailable = speechService.canCreateWithCurrentSettings(
            SpeechRecognitionSettings(locale: locale, requiresOnDevice: false)
        )

        let onDeviceAvailable = speechService.canCreateWithCurrentSettings(
            SpeechRecognitionSettings(locale: locale, requiresOnDevice: true)
        )

        let ttsAvailable = ttsService.isAvailableWithCurrentSettings(
            TextToSpeechSettings(locale: locale)
        )

        return SpeechCapabilities(
            locale: locale,
            speechAvailable: speechAvailable,
            onDeviceAvailable: onDeviceAvailable,
            ttsAvailable: ttsAvailable
        )
    }

    // Resolves capabilities for a full configuration object.
    // Useful for validating existing settings or final save operations.
    func resolve(from config: SpeechConfiguration) -> SpeechCapabilities {
        // Currently, capabilities are strictly bound to Locale, so we delegate.
        // If in the future 'config.useOnlyOnDevice' changes the definition of
        // what is "Available", we can add that logic here.
        resolve(for: Locale(identifier: config.language))
    }

    // MARK: - Helper Methods

    func getCapableLocales() -> [Locale] {
        speechService.getSupportedLocales()
    }

    func resolveLocale(locale: Locale?) -> Locale {
        let supported = speechService.getSupportedLocales()

        if let locale = locale,
           let match = supported.first(where: { $0.identifier == locale.identifier }) {
            return match
        }

        if let current = supported.first(where: { $0.identifier == Locale.current.identifier }) {
            return current
        }

        if let english = supported.first(where: {
            $0.identifier.hasPrefix(AppConstants.defaultLocaleIdentifier)
        }) {
            return english
        }

        return supported.first!
    }

    // Generates settings that are guaranteed to work for the current device state.
    // It automatically handles fallbacks (e.g. disabling on-device if not available).
    func resolveSettings(from config: SpeechConfiguration) -> (
        speech: SpeechRecognitionSettings, tts: TextToSpeechSettings?
    ) {
        let caps = resolve(from: config)

        // Resolve Speech Settings
        // If user wants on-device but it's not available, we assume hybrid/server is acceptable
        // logic: (config.onDevice AND caps.onDevice) -> true.
        let effectiveOnDevice = config.useOnlyOnDevice && caps.onDeviceAvailable

        let speechSettings = SpeechRecognitionSettings(
            locale: caps.locale,
            requiresOnDevice: effectiveOnDevice
        )

        // Resolve TTS Settings
        var ttsSettings: TextToSpeechSettings?
        if caps.ttsAvailable {
            ttsSettings = TextToSpeechSettings(locale: caps.locale)
        }

        return (speechSettings, ttsSettings)
    }
}
