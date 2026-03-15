//
//  APIKeyFieldView.swift
//  ColorBotKids
//
//  Created by ksurikova on 11.03.2026.
//
import SwiftUI

struct APIKeyFieldView: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String
    @State private var isRevealed = false

    var body: some View {
        HStack {
            Group {
                if isRevealed {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .autocorrectionDisabled()
            .autocapitalization(.none)
            .textContentType(.none)
            .keyboardType(.asciiCapable)

            if !text.isEmpty {
                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .onChange(of: text) { if text.isEmpty { isRevealed = false } }
    }
}

#Preview {
    APIKeyFieldView(placeholder: "API Key", text: .constant("my API key"))
}
