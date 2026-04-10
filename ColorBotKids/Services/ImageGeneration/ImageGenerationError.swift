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
    case networkError
    case invalidResponse
    case noImageData
    case rateLimitExceeded
    case serverError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: "image_generation_error_invalidURL")
        case .invalidAPIKey:
            return String(localized: "image_generation_error_invalidAPIKey")
        case .unauthorized:
            return String(localized: "image_generation_error_unauthorized")
        case .accessRestricted:
            return String(localized: "image_generation_error_accessRestricted")
        case .networkError:
            return String(localized: "image_generation_error_networkError")
        case .invalidResponse:
            return String(localized: "image_generation_error_invalidResponse")
        case .noImageData:
            return String(localized: "image_generation_error_noImageData")
        case .rateLimitExceeded:
            return String(localized: "image_generation_error_rateLimitExceeded")
        case .serverError:
            return String(localized: "image_generation_error_serverError")
        }
    }
}
