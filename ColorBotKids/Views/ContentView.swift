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

    var body: some View {
        Group {
            if viewModel.initializationState == .ready {
                buildRoot()
            } else {
                // notStarted and loading
                ProgressIndicatorView(
                    descriptionMessage: String(localized: "onboarding_message_preparingApp")
                )
            }
        }
        .task {
            await viewModel.initialize()
            // Immediately tell the router to compute the first screen
            // Since we are on the @MainActor, this update is thread-safe
            router.finishInitialization()
        }
    }

    @ViewBuilder
    private func buildRoot() -> some View {
        // If the current logic dictates we are in the "Main" part of the app
        if router.rootRoute == .main {
            NavigationStack(path: $router.path) {
                // The Router builds the root of the stack always
                router.buildView(for: .main)
                    .navigationDestination(for: AppRouter.Route.self) { route in
                        // The Router builds any pushed views
                        router.buildView(for: route)
                    }
            }
        } else {
            // Otherwise, show the full-screen configuration views (no stack)
            router.buildView(for: router.rootRoute)
        }
    }
}

#Preview("App Launch - Configured") {
    // These instances use pure mock logic - no camera, mic, or network!
    ContentView(
        viewModel: PreviewMocks.contentViewModel,
        router: PreviewMocks.router
    )
}

#Preview("App Launch - Dumb Previews Examples") {
    // This demonstrates using our Dumb Stubs to bypass initialization logic.
    let stubContainer = StubDependencyContainer()
    let builder = DefaultViewModelBuilder(dependencies: stubContainer)

    return ContentView(
        viewModel: builder.makeContentViewModel(),
        router: AppRouter(
            builder: builder,
            configurationManager: stubContainer.configurationManager,
            permissionManager: stubContainer.permissionManager,
            sessionManager: stubContainer.sessionManager
        )
    )
}
