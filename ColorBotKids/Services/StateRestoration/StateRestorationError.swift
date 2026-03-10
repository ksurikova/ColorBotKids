//
//  StateRestorationError.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.12.2025.
//
import Foundation

enum StateRestorationError: LocalizedError {
    case fileError(String)
    case encodingError(String)
    case decodingError(String)

    var errorDescription: String? {
        switch self {
        case let .fileError(details):
            let format = NSLocalizedString(
                "state_restoration_error_fileError",
                comment: "StateRestorationError"
            )
            return String(format: format, details)
        case let .encodingError(details):
            let format = NSLocalizedString(
                "state_restoration_error_encodingError",
                comment: "StateRestorationError"
            )
            return String(format: format, details)
        case let .decodingError(details):
            let format = NSLocalizedString(
                "state_restoration_error_decodingError",
                comment: "StateRestorationError"
            )
            return String(format: format, details)
        }
    }
}
