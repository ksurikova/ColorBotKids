//
//  StateStorage.swift
//  ColorBotKids
//
//  Created by ksurikova on 30.11.2025.
//
import Foundation
import SwiftUI

protocol StateStorage {
    func setCurrentStateURL(_ url: URL?)
    func getCurrentStateURL() -> URL?
}

// Environment Key for dependency injection
private struct StateStorageKey: EnvironmentKey {
    static let defaultValue: StateStorage = UserDefaultsStateStorage()
}

extension EnvironmentValues {
    var stateStorage: StateStorage {
        get { self[StateStorageKey.self] }
        set { self[StateStorageKey.self] = newValue }
    }
}
