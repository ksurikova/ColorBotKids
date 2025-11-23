//
//  Extensions.swift
//  ColorBotKids
//
//  Created by ksurikova on 31.10.2025.
//
import Foundation

extension Locale {
    static func normalize(_ identifier: String) -> String {
        identifier.replacingOccurrences(of: "-", with: "_")
    }

    var localizedDisplayName: String {
        Locale.current.localizedString(forIdentifier: identifier)
            ?? identifier
    }
}
