//
//  ColorBotKidsApp.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//

import SwiftUI

enum AppBootstrapState {
    case supported(ContentViewModel, AppRouter)
    case unsupported(String)
}

// In App initialization
@main
struct ColorBotKidsApp: App {
    private let bootstrapState: AppBootstrapState

    init() {
        // Change this to MockDependencyContainer.self to test mocks
        let containerType = ProductionDependencyContainer.self

        if let errorMessage = containerType.systemUnavailabilityReason() {
            bootstrapState = AppBootstrapState.unsupported(errorMessage)
        } else {
            // Initialize the concrete services
            let container = containerType.init()

            let builder = DefaultViewModelBuilder(dependencies: container)
            // Router gets the builder
            let router = AppRouter(
                builder: builder,
                configurationManager: container.configurationManager,
                permissionManager: container.permissionManager,
                sessionManager: container.sessionManager
            )

            let contentVM = builder.makeContentViewModel()

            bootstrapState = .supported(contentVM, router)
        }
    }

    var body: some Scene {
        WindowGroup {
            switch bootstrapState {
            case let .supported(contentVM, router):
                ContentView(viewModel: contentVM, router: router)
            case let .unsupported(reason):
                UnsupportedView(reason: reason)
            }
        }
    }
}
