//
//  DefaultIcon.swift
//  ColorBotKids
//
//  Created by ksurikova on 22.10.2025.
//
import SwiftUI

struct DefaultIcon<S: ShapeStyle>: View {
    let name: String
    let foregroundStyle: S

    var body: some View {
        Image(systemName: name)
            .font(.system(size: 70))
            .foregroundStyle(
                foregroundStyle
            )
            .padding(.top, 16)
    }
}

#Preview() {
    DefaultIcon(name: "waveform.circle.fill", foregroundStyle:
        LinearGradient.bluePurple)
}
