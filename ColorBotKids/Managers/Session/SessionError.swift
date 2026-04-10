//
//  SessionError.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.02.2026.
//

import Foundation

enum SessionError: LocalizedError {
    case noActiveSession
    case noDrawingData

    var errorDescription: String? {
        switch self {
        case .noActiveSession:
            return String(localized: "session_error_noActiveSession")
        case .noDrawingData:
            return String(localized: "session_error_noDrawingData")
        }
    }
}
