//
//  CriticalErrorPieceView.swift
//  ColorBotKids
//
//  Created by ksurikova on 22.03.2026.
//
import SwiftUI

struct CriticalErrorPieceView: View {
    let title: LocalizedStringKey
    let text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.octagon.fill")
                .font(.title3)
                .foregroundColor(.red)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.red)

                Text(text)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        // Light red background with a subtle border
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 4) // Match your inner spacing
    }
}

#Preview {
    CriticalErrorPieceView(
        title: "Error title",
        text: "Error description that can be multiple lines and should be fully visible without truncation."
    )
}
