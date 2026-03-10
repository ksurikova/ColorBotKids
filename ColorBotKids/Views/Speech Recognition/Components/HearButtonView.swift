//
//  HearButtonView.swift
//  ColorBotKids
//
//  Created by ksurikova on 9.12.2025.
//
import SwiftUI

struct HearButtonView: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 14, weight: .semibold))
                Text("main_action_hearAgain")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.orange)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule().fill(.orange.opacity(0.15))
            )
        }
        .transition(.scale.combined(with: .opacity))
        .padding(.bottom, 20)
    }
}

#Preview("") {
    HearButtonView(action: {})
}
