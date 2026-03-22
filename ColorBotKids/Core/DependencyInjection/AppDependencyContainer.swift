//
//  AppDependencyContainer.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//

import SwiftUI

@MainActor
protocol AppDependencyContainer {
    var mainServicesManager: MainServicesManager { get }
    var permissionManager: PermissionManager { get }
    var sessionManager: SessionManager { get }
    var imageToolingManager: ImageToolingManager { get }
    var contentViewModel: ContentViewModel { get }
    var router: AppRouter { get }
    var speechConfigurationDraftService: SpeechConfigurationDraftService { get }

    // Returns nil if supported, or an error message if unsupported
    static func systemUnavailabilityReason() -> String?
}
