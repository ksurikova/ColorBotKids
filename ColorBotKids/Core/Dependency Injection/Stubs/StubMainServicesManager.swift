//
//  StubMainServicesManager.swift
//  ColorBotKids
//
//  Created by GitHub Copilot on 06.05.2026.
//

import Combine
import Foundation

final class StubMainServicesManager: MainServicesManaging {
    var services: AppMainServices?

    init(services: AppMainServices? = nil) {
        self.services = services
    }

    func prepareServices() throws {}

    func createServicesIfNeeded() throws {}

    func configureTTSCallbacks(
        onVolumeWarning: @escaping (VolumeWarningLevel) -> Void,
        onDidFailToPlay: @escaping () -> Void
    ) {}
}
