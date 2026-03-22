//
//  SpeechLanguageSection.swift
//  ColorBotKids
//
//  Created by ksurikova on 9.02.2026.
//
import SwiftUI

struct SpeechLanguageSection: View {
    @Binding var selectedLocale: Locale
    let supportedLocales: [Locale]

    var body: some View {
        HStack {
            Text("settings_label_language").plainStyle()
            Picker("", selection: $selectedLocale) {
                ForEach(supportedLocales, id: \.identifier) { locale in
                    Text(locale.localizedDisplayName).tag(locale)
                }
            }
            .defaultStyle()
        }
    }
}

#Preview {
    SpeechLanguageSection(
        selectedLocale: Binding.constant(Locale(identifier: "en-US")),
        supportedLocales: [
            Locale(identifier: "en-US"),
            Locale(identifier: "fr-FR"),
            Locale(identifier: "ru-RU"),
        ]
    )
}
