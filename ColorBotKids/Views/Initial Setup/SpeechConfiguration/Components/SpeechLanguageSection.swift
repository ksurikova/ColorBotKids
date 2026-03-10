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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("settings_label_language").plainStyle()
                Spacer()
                Picker("", selection: $selectedLocale) {
                    ForEach(supportedLocales, id: \.identifier) { locale in
                        Text(locale.localizedDisplayName).tag(locale)
                    }
                }
                .defaultStyle()
            }
        }
    }
}
