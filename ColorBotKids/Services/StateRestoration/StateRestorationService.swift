//
//  StareRestorationService.swift
//  ColorBotKids
//
//  Created by ksurikova on 28.11.2025.
//
import SwiftUI

protocol StateRestorationService {
    func saveState(image: UIImage, drawingData: Data) throws -> URL
    func loadState(from url: URL) -> (image: UIImage, drawingData: Data)?
    func clearState(at url: URL?)
}

// Environment Key for dependency injection
private struct StateRestorationServiceKey: EnvironmentKey {
    static let defaultValue: StateRestorationService = DefaultStateRestorationService()
}

extension EnvironmentValues {
    var stateRestorationService: StateRestorationService {
        get { self[StateRestorationServiceKey.self] }
        set { self[StateRestorationServiceKey.self] = newValue }
    }
}
