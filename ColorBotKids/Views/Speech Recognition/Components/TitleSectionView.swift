//
//  TitleSectionView.swift
//  ColorBotKids
//
//  Created by ksurikova on 9.12.2025.
//
import SwiftUI

struct TitleSectionView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("main_title_wantToColor")
                .titleStyle()
        }
        .padding(.top, 40)
    }
}

#Preview("") {
    TitleSectionView()
}
