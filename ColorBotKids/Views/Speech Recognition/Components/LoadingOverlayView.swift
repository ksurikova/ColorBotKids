//
//  LoadingOverlayView.swift
//  ColorBotKids
//
//  Created by ksurikova on 9.12.2025.
//
import SwiftUI

struct LoadingOverlayView: View {
    let message: String

    var body: some View {
        ZStack {
            DimmerBackgroundView()
            ProgressIndicatorView(descriptionMessage: message)
        }
    }
}

#Preview("") {
    LoadingOverlayView(message: "loading...")
}
