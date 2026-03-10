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
    case unknownError(Error?)

    var errorDescription: String? {
        switch self {
        case .noPermission:
            return NSLocalizedString(
                "image_save_error_noPermission",
                comment: "ImageSaveServiceError"
            )
        case .invalidImageToSave:
            return NSLocalizedString(
                "image_save_error_invalidImageToSave",
                comment: "ImageSaveServiceError"
            )
        case .savingIsInterrupted:
            return NSLocalizedString(
                "image_save_error_savingIsInterrupted",
                comment: "ImageSaveServiceError"
            )
        case let .unknownError(error):
            let format = NSLocalizedString(
                "image_save_error_unknownError",
                comment: "ImageSaveServiceError"
            )
            return String(format: format, error?.localizedDescription ?? "unknown error")
        }
    }
}
