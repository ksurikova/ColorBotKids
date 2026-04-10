//
//  StateRestorationError.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.12.2025.
//
import Foundation

enum StateRestorationError: LocalizedError {
    case directoryCreationFailed
    case imageWriteFailed
    case drawingWriteFailed
    case imageEncodingFailed
    case fileNotFound
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .directoryCreationFailed:
            return String(localized: "state_restoration_error_directoryCreationFailed")
        case .imageWriteFailed:
            return String(localized: "state_restoration_error_imageWriteFailed")
        case .drawingWriteFailed:
            return String(localized: "state_restoration_error_drawingWriteFailed")
        case .imageEncodingFailed:
            return String(localized: "state_restoration_error_imageEncodingFailed")
        case .fileNotFound:
            return String(localized: "state_restoration_error_fileNotFound")
        case .decodingFailed:
            return String(localized: "state_restoration_error_decodingFailed")
        }
    }
}
