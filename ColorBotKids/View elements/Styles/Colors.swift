//
//  Colors.swift
//  ColorBotKids
//
//  Created by ksurikova on 22.10.2025.
//
import SwiftUI

extension LinearGradient {
    static let bluePurple = LinearGradient(
        colors: [.blue, .purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let bluePurpleLight = LinearGradient(
        colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
        startPoint: .leading,
        endPoint: .trailing
    )
}
