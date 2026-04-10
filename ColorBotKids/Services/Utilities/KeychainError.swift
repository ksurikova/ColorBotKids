//
//  KeychainError.swift
//  ColorBotKids
//
//  Created by ksurikova on 31.03.2026.
//
import Foundation

enum KeychainError: LocalizedError {
    case saveFailed
    case readFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            String(localized: "keychain_error_saveFailed")
        case .readFailed:
            String(localized: "keychain_error_readFailed")
        }
    }
}
