//
//  ConfigurationError.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//

import Foundation

enum ConfigurationError: LocalizedError {
    case corruptedData
    case failedToSave
    case failedToDelete
    case aiConfigurationMissing
    case aiConfigurationInvalid
    case speechConfigurationMissing
    case speechConfigurationInvalid
    case configurationInvalid

    var errorDescription: String? {
        switch self {
        case .corruptedData:
            return String(localized: "configuration_error_corruptedData")
        case .failedToSave:
            return String(localized: "configuration_error_failedToSave")
        case .failedToDelete:
            return String(localized: "configuration_error_failedToDelete")
        case .aiConfigurationMissing:
            return String(localized: "configuration_error_aiConfigurationMissing")
        case .aiConfigurationInvalid:
            return String(localized: "configuration_error_aiConfigurationInvalid")
        case .speechConfigurationMissing:
            return String(localized: "configuration_error_speechConfigurationMissing")
        case .speechConfigurationInvalid:
            return String(localized: "configuration_error_speechConfigurationInvalid")
        case .configurationInvalid:
            return String(localized: "configuration_error_invalidConfiguration")
        }
    }
}
