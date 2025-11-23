//
//  DimmerBackgroundView.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//
import SwiftUI

struct DimmerBackgroundView: View {
    var body: some View {
        Color.primary
            .opacity(0.2)
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    DimmerBackgroundView()
}
