//
//  ImageSaveServiceError.swift
//  ColorBotKids
//
//  Created by ksurikova on 05.12.2025.
//

import Foundation

enum ImageSaveServiceError: LocalizedError {
    case noPermission
    case invalidImageToSave
    case savingIsInterrupted
    case unknownError

    var errorDescription: String? {
        switch self {
        case .noPermission:
            return String(localized: "image_save_error_noPermission")
        case .invalidImageToSave:
            return String(localized: "image_save_error_invalidImageToSave")
        case .savingIsInterrupted:
            return String(localized: "image_save_error_savingIsInterrupted")
        case .unknownError:
            return String(localized: "image_save_error_unknownError")
        }
    }
}
