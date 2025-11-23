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
    case networkError(Error)
    case invalidResponse
    case noImageData
    case imageDecodingFailed
    case rateLimitExceeded
    case serverError(statusCode: Int, message: String?)
    case promptTooLong(maxLength: Int)
    case invalidPrompt

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API endpoint URL"
        case .invalidAPIKey:
            return "API key is missing or invalid"
        case let .networkError(error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .noImageData:
            return "No image data received"
        case .imageDecodingFailed:
            return "Failed to decode image"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later"
        case let .serverError(code, message):
            return "Server error (\(code)): \(message ?? "Unknown error")"
        case let .promptTooLong(maxLength):
            return "Prompt exceeds maximum length of \(maxLength) characters"
        case .invalidPrompt:
            return "Prompt contains invalid content"
        }
    }
}
