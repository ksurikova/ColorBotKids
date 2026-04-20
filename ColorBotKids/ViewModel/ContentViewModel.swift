//
//  ContentViewModel.swift
//  ColorBotKids
//
//  Created by ksurikova on 06.03.2026.
//

import Combine
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
    enum InitializationState: Equatable {
        case notStarted
        case loading
        case ready

        var isReady: Bool {
            if case .ready = self { return true }
            return false
        }
    }

    @Published private(set) var initializationState: InitializationState = .notStarted

    // Dependencies
    let mainServicesManager: MainServicesManager
    let permissionManager: PermissionManager
    let sessionManager: SessionManager
    let imageToolingManager: ImageToolingManager

    init(dependencies: AppDependencies) {
        mainServicesManager = dependencies.mainServicesManager
        permissionManager = dependencies.permissionManager
        sessionManager = dependencies.sessionManager
        imageToolingManager = dependencies.imageToolingManager
    }

    func initialize() async {
        guard initializationState == .notStarted else {
            print("⚠️ Already initialized")
            return
        }

        initializationState = .loading

        // Load configuration, check permissions, and restore session in parallel (because these are
        // independent operations)
        async let configLoad: Void = loadConfiguration()
        async let permissionsCheck: Void = permissionManager.checkAll()
        async let sessionRestore: Void = sessionManager.restoreLast()

        // Wait for all independent tasks to complete
        _ = await(configLoad, permissionsCheck, sessionRestore)

        initializationState = .ready
    }

    private func loadConfiguration() async {
        do {
            try mainServicesManager.configurationManager.load()
        } catch {
            print("⚠️ Configuration load failed silently: \(error.localizedDescription)")
        }
    }
}
