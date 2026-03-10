//
//  Extensions.swift
//  ColorBotKids
//
//  Created by ksurikova on 31.10.2025.
//
import Foundation

extension Locale {
    // normalize using BCP 47 language tags
    static func normalize(_ identifier: String) -> String {
        identifier.replacingOccurrences(of: "_", with: "-")
    }

    var localizedDisplayName: String {
        Locale.current.localizedString(forIdentifier: identifier)
            ?? identifier
    }
}

enum Helpers {
    static func formatError(_ error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            return description
        }
        return error.localizedDescription
    }
}
