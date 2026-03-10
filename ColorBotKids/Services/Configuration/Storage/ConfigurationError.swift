//
//  ConfigurationError.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//

import Foundation

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
            return "Configuration file not found"
        case .corruptedData:
            return "Configuration data corrupted"
        case .failedToSave:
            return "Failed to save configuration"
        case .failedToDelete:
            return "Failed to delete configuration"
        case .invalidConfiguration:
            return "Invalid configuration"
        case .aiConfigurationMissing:
            return "AI configuration missing"
        case .aiConfigurationInvalid:
            return "AI configuration invalid"
        case .speechConfigurationMissing:
            return "Speech configuration missing"
        case .speechConfigurationInvalid:
            return "Speech configuration invalid"
        case let .unknown(error):
            return error.localizedDescription
        }
    }

    var asAppError: AppError {
        switch self {
        case .aiConfigurationMissing:
            return .aiConfigurationInvalid("AI configuration is missing")
        case .speechConfigurationMissing:
            return .speechConfigurationInvalid("Speech configuration is missing")
        case .speechConfigurationInvalid:
            return .speechConfigurationInvalid("Speech configuration is invalid for this device")
        default:
            return .configurationFailed(localizedDescription)
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
