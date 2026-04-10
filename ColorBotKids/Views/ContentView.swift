//
//  ContentView.swift
//  ColorBotKids
//
//  Created by ksurikova on 25.11.2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    @ObservedObject var router: AppRouter

    init(viewModel: ContentViewModel, router: AppRouter) {
        self.viewModel = viewModel
        self.router = router
    }

    var body: some View {
        Group {
            switch viewModel.initializationState {
            case .notStarted, .loading:
                ProgressIndicatorView(
                    descriptionMessage: String(localized: "onboarding_message_preparingApp")
                )

            case .ready:
                router.buildView(path: $router.path)
            }
        }
        .task {
            // Start initialization when the view appears
            await viewModel.initialize()
        }
        .onChange(of: viewModel.initializationState) { _, newState in
            if case .ready = newState {
                router.finishInitialization()
            }
        }
    }
}
