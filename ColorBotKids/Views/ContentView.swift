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

            case let .failed(error):
                ErrorView(error: error) {
                    await viewModel.initialize()
                }

            case .ready:
                router.buildView()
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

    // MARK: - Error View

    struct ErrorView: View {
        let error: AppError
        let retryAction: () async -> Void

        var body: some View {
            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.red)

                Text("common_errorTitle_error")
                    .font(.title)

                Text(error.errorDescription ?? String(localized: "common_errorDescription_unknown"))
                    .multilineTextAlignment(.center)

                Button("common_action_retry") {
                    Task {
                        await retryAction()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}
