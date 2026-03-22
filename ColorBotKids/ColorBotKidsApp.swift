//
//  ColorBotKidsApp.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//

import SwiftUI

enum AppBootstrapState {
    case supported(AppDependencyContainer)
    case unsupported(String)
}

// In App initialization
@main
struct ColorBotKidsApp: App {
    private let bootstrapState: AppBootstrapState

    init() {
        // Change this to MockDependencyContainer.self to test mocks
        let containerType = ProductionDependencyContainer.self

        // App.init() runs on the main thread, but the compiler doesn't know this implicitly.
        // Since our containers are @MainActor (because they hold ViewModels), we must
        // wrap their creation in assumeIsolated to satisfy Swift concurrency safety.
        let state = MainActor.assumeIsolated {
            if let errorMessage = containerType.systemUnavailabilityReason() {
                return AppBootstrapState.unsupported(errorMessage)
            } else {
                return AppBootstrapState.supported(containerType.init())
            }
        }

        bootstrapState = state
    }

    var body: some Scene {
        WindowGroup {
            switch bootstrapState {
            case let .supported(container):
                ContentView(viewModel: container.contentViewModel, router: container.router)
            case let .unsupported(reason):
                UnsupportedView(reason: reason)
            }
        }
    }
}
