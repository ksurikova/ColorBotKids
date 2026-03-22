//
//  UnsupportedView.swift
//  ColorBotKids
//
//  Created by ksurikova on 9.02.2026.
//
import SwiftUI

struct UnsupportedView: View {
    var reason: String?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.slash")

            Text("unsupported_title")
                .font(.title)

            if let reason = reason {
                Text(reason)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("unsupported_message")
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}
