//
//  ProgressIndicatorView.swift
//  ColorBotKids
//
//  Created by ksurikova on 17.10.2025.
//
import SwiftUI

struct ProgressIndicatorView: View {
    let descriptionMessage: String

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.5)

            Text(descriptionMessage)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(radius: 5)
        )
    }
}

#Preview {
    ProgressIndicatorView(descriptionMessage: "Signing up in progress...")
}
