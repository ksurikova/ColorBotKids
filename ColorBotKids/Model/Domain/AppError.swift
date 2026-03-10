//
//  AppError.swift
//  ColorBotKids
//
//  Created by ksurikova on 4.02.2026.
//

import Foundation

enum AppError: LocalizedError, Equatable, Hashable {
    case initializationFailed
    case configurationFailed(String)
    case aiConfigurationInvalid(String)
    case speechConfigurationInvalid(String)
    case serviceCreationFailed(String)
    case permissionDenied(AnyPermission)
    case stateRestorationFailed
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .initializationFailed:
            return String(localized: "app_error_initializationFailed")
        case let .configurationFailed(message):
            return String(
                format: NSLocalizedString("app_error_configurationFailed", comment: ""),
                message
            )
        case let .aiConfigurationInvalid(message):
            return String(
                format: NSLocalizedString("app_error_aiConfigurationInvalid", comment: ""),
                message
            )
        case let .speechConfigurationInvalid(message):
            return String(
                format: NSLocalizedString("app_error_speechConfigurationInvalid", comment: ""),
                message
            )
        case let .serviceCreationFailed(message):
            return String(
                format: NSLocalizedString("app_error_serviceCreationFailed", comment: ""),
                message
            )
        case let .permissionDenied(definition): // Assuming definition has a string representation
            // or description
            return String(
                format: NSLocalizedString("app_error_permissionDenied", comment: ""),
                String(describing: definition)
            )
        case .stateRestorationFailed:
            return String(localized: "app_error_stateRestorationFailed")
        case let .unknown(message):
            return message
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }

    static func map(_ error: ConfigurationError) -> Self {
        switch error {
        case .aiConfigurationMissing:
            return .aiConfigurationInvalid(String(localized: "app_error_aiConfigurationMissing"))

        case .speechConfigurationMissing:
            return .speechConfigurationInvalid(
                String(localized: "app_error_speechConfigurationMissing")
            )

        case .speechConfigurationInvalid:
            return .speechConfigurationInvalid(
                String(localized: "app_error_speechConfigurationInvalidDevice")
            )

        case .unknown, .aiConfigurationInvalid, .corruptedData, .failedToDelete, .failedToSave,
             .fileNotFound, .invalidConfiguration:
            return .configurationFailed(String(localized: "app_error_configurationError"))
        }
    }
}
