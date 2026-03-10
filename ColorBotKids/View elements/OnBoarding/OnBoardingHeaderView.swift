//
//  OnBoardingHeaderView.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.12.2025.
//
import SwiftUI

struct OnboardingHeaderView: View {
    let icon: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey?
    let gradient: AnyShapeStyle

    init(
        icon: String,
        title: LocalizedStringKey,
        description: LocalizedStringKey? = nil,
        gradient: AnyShapeStyle = AnyShapeStyle(LinearGradient.bluePurple)
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.gradient = gradient
    }

    var body: some View {
        VStack(spacing: 16) {
            DefaultIcon(name: icon, foregroundStyle: gradient)
            Text(title).mainStyle()
            if let description {
                Text(description)
                    .plainStyle()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
        }
    }
}

#Preview("") {
    OnboardingHeaderView(
        icon: "brain.head.profile",
        title: "onboarding_title_AI",
        description: nil,
        gradient: AnyShapeStyle(LinearGradient.bluePurple)
    )
}
