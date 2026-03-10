//
//  Picker Style.swift
//  ColorBotKids
//
//  Created by ksurikova on 24.10.2025.
//
import SwiftUI

extension Picker {
    func defaultStyle() -> some View {
        pickerStyle(.menu)
            .tint(.black)
            .padding(4)
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
}

#Preview("default picker style") {
    Picker("Language", selection: Binding.constant("en-US")) {
        Text("English").tag(AppConstants.defaultLocaleIdentifier)
        Text("French").tag("fr-FR")
        Text("Spanish").tag("es-ES")
    }.defaultStyle()
}
