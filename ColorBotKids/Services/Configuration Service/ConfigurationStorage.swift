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
    func deleteAll() throws
}

enum ConfigurationError: LocalizedError {
    case fileNotFound
    case corruptedData
    case failedToSave
    case failedToDelete
    case invalidConfiguration
    // specific validation errors
    case aiConfigurationMissing
    case aiConfigurationInvalid
    case speechConfigurationMissing
    case speechConfigurationInvalid

    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Configuration file not found."
        case .corruptedData:
            return "Saved configuration is corrupted and cannot be loaded."
        case .failedToSave:
            return "Failed to save configuration."
        case .failedToDelete:
            return "Failed to reset configuration data."
        case .invalidConfiguration:
            return "Configuration data is invalid or incomplete."
        case .aiConfigurationMissing:
            return "AI settings not found. Let's set them up."
        case .aiConfigurationInvalid:
            return "AI settings are invalid. Let's fix them."
        case .speechConfigurationMissing:
            return "Speech settings not found. Let's set them up."
        case .speechConfigurationInvalid:
            return "Speech settings are invalid. Let's fix them."
        case let .unknown(error):
            return error.localizedDescription
        }
    }

    var requiresAIConfiguration: Bool {
        switch self {
        case .fileNotFound, .corruptedData, .invalidConfiguration,
             .aiConfigurationMissing, .aiConfigurationInvalid:
            return true
        default:
            return false
        }
    }

    var requiresSpeechConfiguration: Bool {
        switch self {
        case .speechConfigurationMissing, .speechConfigurationInvalid:
            return true
        default:
            return false
        }
    }
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
