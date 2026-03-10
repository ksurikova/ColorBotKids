//
//  BackGroundView.swift
//  ColorBotKids
//
//  Created by ksurikova on 22.10.2025.
//
import SwiftUI

struct BackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color.blue.opacity(0.05),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
}
