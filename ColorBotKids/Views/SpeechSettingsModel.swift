//
//  SpeechSettingsModel.swift
//  ColorBotKids
//
//  Created by ksurikova on 18.11.2025.
//
import Foundation

struct SpeechSettingsModel: Equatable {
    var selectedLocale: Locale
    var useOnlyOnDevice: Bool
    var autoPlayConfirmation: Bool
    var ttsUnavailableForLocale: Bool = false

    var supportedLocales: [Locale]

    private init(
        selectedLocale: Locale,
        useOnlyOnDevice: Bool,
        autoPlayConfirmation: Bool,
        supportedLocales: [Locale]
    ) {
        self.selectedLocale = selectedLocale
        self.useOnlyOnDevice = useOnlyOnDevice
        self.autoPlayConfirmation = autoPlayConfirmation
        self.supportedLocales = supportedLocales
    }

    static func create(
        supportedLocales: [Locale],
        savedConfig: SpeechConfiguration?
    ) -> Self {
        guard !supportedLocales.isEmpty else {
            assertionFailure("Cannot create form without supported locales")
            // Return a minimal form - this is a critical error state
            return Self(
                selectedLocale: Locale(identifier: "en-US"),
                useOnlyOnDevice: false,
                autoPlayConfirmation: false,
                supportedLocales: []
            )
        }

        let selectedLocale = selectInitialLocale(from: supportedLocales, config: savedConfig)
        let useOnlyOnDevice = savedConfig?.useOnlyOnDevice ?? false
        let autoPlayConfirmation = savedConfig?.autoPlayConfirmation ?? false

        return Self(
            selectedLocale: selectedLocale,
            useOnlyOnDevice: useOnlyOnDevice,
            autoPlayConfirmation: autoPlayConfirmation,
            supportedLocales: supportedLocales
        )
    }

    // Returns the best locale to use based on saved config and available locales
    // Priority: saved config → user's current locale → English → first available
    static func selectInitialLocale(
        from supportedLocales: [Locale],
        config: SpeechConfiguration?
    ) -> Locale {
        // Validate we have locales to work with
        guard !supportedLocales.isEmpty else {
            assertionFailure("No supported locales available")
            return Locale(identifier: "en-US") // Fallback
        }

        if let savedLanguage = config?.language {
            let savedLocale = Locale(identifier: savedLanguage)
            if supportedLocales.contains(where: { $0.identifier == savedLocale.identifier }) {
                return savedLocale
            }
            print("Saved locale '\(savedLanguage)' is no longer supported")
        }

        let currentLocale = Locale.current
        if supportedLocales.contains(where: { $0.identifier == currentLocale.identifier }) {
            return currentLocale
        }

        if let englishLocale = supportedLocales.first(where: {
            $0.identifier.hasPrefix("en-US")
        }) {
            return englishLocale
        }

        return supportedLocales[0]
    }
}
