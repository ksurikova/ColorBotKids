//
//  ConfigurationStorage.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//
import Foundation
import SwiftUI

protocol ConfigurationStorage {
    func loadConfiguration() throws -> AppConfiguration
    func saveAIConfiguration(_ config: AIConfiguration) throws
    func saveSpeechConfiguration(_ config: SpeechConfiguration) throws
    func saveAllConfigurations(ai: AIConfiguration, speech: SpeechConfiguration) throws
    func deleteAll() throws
}

private struct ConfigurationStorageKey: EnvironmentKey {
    static let defaultValue: ConfigurationStorage = MockConfigurationStorage()
}

extension EnvironmentValues {
    var configurationStorage: ConfigurationStorage {
        get { self[ConfigurationStorageKey.self] }
        set { self[ConfigurationStorageKey.self] = newValue }
    }
}
