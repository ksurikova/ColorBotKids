//
//  CloseButton.swift
//  ColorBotKids
//
//  Created by ksurikova on 21.10.2025.
//
import SwiftUI

struct CloseButton: View {
    @Binding var isVisible: Bool
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                isVisible = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                action()
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview() {
    CloseButton(isVisible: Binding.constant(true), action: {})
}
