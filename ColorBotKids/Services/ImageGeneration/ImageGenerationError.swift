//
//  ImageGenerationError.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//
import Foundation

enum ImageGenerationError: LocalizedError {
    case invalidURL
    case invalidAPIKey
    case unauthorized
    case accessRestricted
    case networkError(Error)
    case invalidResponse
    case noImageData
    case rateLimitExceeded
    case serverError(statusCode: Int, message: String?)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString(
                "image_generation_error_invalidURL",
                comment: "ImageGenerationError"
            )
        case .invalidAPIKey:
            return String(
                localized: "image_generation_error_invalidAPIKey",
                defaultValue: "Invalid API configuration. Please check your settings.",
                comment: "ImageGenerationError"
            )
        case .unauthorized:
            return String(
                localized: "image_generation_error_unauthorized",
                defaultValue: "Unauthorized: Please check your API Key in Settings.",
                comment: "ImageGenerationError"
            )
        case .accessRestricted:
            return String(
                localized: "image_generation_error_accessRestricted",
                defaultValue: "Access Restricted: Please check your account permissions or API settings.",
                comment: "ImageGenerationError"
            )
        case let .networkError(error):
            let format = NSLocalizedString(
                "image_generation_error_networkError",
                comment: "ImageGenerationError"
            )
            return String(format: format, error.localizedDescription)
        case .invalidResponse:
            return NSLocalizedString(
                "image_generation_error_invalidResponse",
                comment: "ImageGenerationError"
            )
        case .noImageData:
            return NSLocalizedString(
                "image_generation_error_noImageData",
                comment: "ImageGenerationError"
            )
        case .rateLimitExceeded:
            return String(
                localized: "image_generation_error_rateLimitExceeded",
                defaultValue: "Rate Limit Exceeded: Please try again later.",
                comment: "ImageGenerationError"
            )
        case let .serverError(code, message):
            let format = NSLocalizedString(
                "image_generation_error_serverError",
                comment: "ImageGenerationError"
            )
            return String(format: format, code, message ?? "Unknown error")
        }
    }
}
