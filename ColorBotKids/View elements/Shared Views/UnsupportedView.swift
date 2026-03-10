//
//  UnsupportedView.swift
//  ColorBotKids
//
//  Created by ksurikova on 9.02.2026.
//
import SwiftUI

struct UnsupportedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.slash")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("unsupported_title")
                .font(.title)

            Text("unsupported_message")
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
