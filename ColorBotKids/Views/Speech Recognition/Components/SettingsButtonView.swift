//
//  SettingsButtonView.swift
//  ColorBotKids
//
//  Created by ksurikova on 9.12.2025.
//
import SwiftUI

struct SettingsButtonView: View {
    @Binding var showSettings: Bool

    var body: some View {
        HStack {
            Spacer()
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding(.top, 40)
    }
}

#Preview("") {
    SettingsButtonView(showSettings: .constant(true))
}
