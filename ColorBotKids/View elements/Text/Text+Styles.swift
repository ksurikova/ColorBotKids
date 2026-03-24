//
//  Text styles.swift
//  ColorBotKids
//
//  Created by ksurikova on 22.10.2025.
//
import SwiftUI

extension Text {
    func captionStyle() -> some View {
        font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }

    func mainStyle() -> some View {
        font(.system(size: 28, weight: .bold, design: .rounded))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }

    func plainStyle() -> some View {
        font(.system(size: 17))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 32)
    }

    func titleStyle() -> some View {
        font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundStyle(
                LinearGradient.bluePurple
            )
    }

    func labelStyle() -> some View {
        font(.system(size: 17, weight: .bold, design: .rounded))
    }

    func permissionTitle() -> some View {
        font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.primary)
    }

    func permissionDescription() -> some View {
        font(.system(size: 15))
            .foregroundColor(.secondary)
            .lineLimit(2)
    }

    func confirmationTitle() -> some View {
        font(.system(size: 26, weight: .bold, design: .rounded))
            .multilineTextAlignment(.center)
    }

    func confirmationDescription() -> some View {
        font(.system(size: 19, weight: .medium, design: .rounded))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .lineSpacing(4)
    }

    func confirmationButtonLabel() -> some View {
        font(.system(size: 19, weight: .bold, design: .rounded))
    }

    func bannerMessageStyle() -> some View {
        font(.system(size: 15, weight: .medium))
            .foregroundStyle(.primary)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("caption") {
    Text("You can always enable this later in Settings").captionStyle()
}

#Preview("main") {
    Text("Voice Access Needed").mainStyle()
}

#Preview("plain") {
    Text("To create images from your voice, we need access to:").plainStyle()
}

#Preview("title") {
    Text("I want to color...").titleStyle()
}

#Preview("label") {
    Text("Draw it!").titleStyle()
}

#Preview("permissionTitle") {
    Text("I want to color...").permissionTitle()
}

#Preview("permissionDescription") {
    Text("Draw it!").permissionDescription()
}
