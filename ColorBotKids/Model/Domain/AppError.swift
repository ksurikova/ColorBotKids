//
//  AppError.swift
//  ColorBotKids
//
//  Created by ksurikova on 4.02.2026.
//

import Foundation

// MARK: - Kid Friendly Errors

enum KidFriendlyError: LocalizedError, Equatable, Hashable {
    case generic
    case aiServiceDown
    case microphoneOff(AppError) // Nested technical detail
    case tryAgainLater
    case cantSavePicture(AppError) // Nested technical detail
    case needsParentsHelp(AppError) // Nested technical detail
    case noSpeechDetected
    case configurationInvalid(AppError) // Nested technical detail

    var errorDescription: String? {
        switch self {
        case .generic:
            return String(localized: "kid_error_generic")
        case .aiServiceDown:
            return String(localized: "kid_error_ai_down")
        case .microphoneOff:
            return String(localized: "kid_error_mic_off")
        case .cantSavePicture:
            return String(localized: "kid_error_cant_save_picture")
        case .needsParentsHelp:
            return String(localized: "kid_error_needs_parents_help")
        case .noSpeechDetected:
            return String(localized: "kid_error_no_speech_detected")
        case .tryAgainLater:
            return String(localized: "kid_error_tryAgainLater")
        case .configurationInvalid:
            return String(localized: "kid_error_configuration_invalid")
        }
    }

    // Computed property to extract the technical message for the Parent's UI
    var parentDetail: String? {
        switch self {
        case let .microphoneOff(error),
             let .cantSavePicture(error),
             let .needsParentsHelp(error),
             let .configurationInvalid(error):
            return error.localizedDescription
        default:
            return nil
        }
    }
}

// MARK: - Default (Parent/Formal) App Error

enum AppError: LocalizedError, Equatable, Hashable {
    case unknown(String)

    case configurationFailed(String)
    case aiConfigurationInvalid
    case speechConfigurationInvalid
    case configurationInvalid

    case speechServiceNotExist
    case aiServiceNotExist

    case noPermissionToSaveImage
    case invalidImageToSave
    case savingImageIsInterrupted
    case aiServiceError
    case aiServiceInvalidURL

    case invalidAIAPISettings(String)
    case aiServiceRateLimitExceeded(String)

    case unknownSpeechRecognitionError(String)
    case unknownImageSaveServiceError(String)

    var errorDescription: String? {
        switch self {
        case let .configurationFailed(message):
            let baseString = String(localized: "app_error_configurationFailed")
            return "\(baseString) \(message)"
        case .aiConfigurationInvalid:
            return String(localized: "app_error_aiConfigurationInvalid")
        case .speechConfigurationInvalid:
            return String(localized: "app_error_speechConfigurationInvalid")
        case .configurationInvalid:
            return String(localized: "app_error_configurationInvalid")
        case .speechServiceNotExist:
            return String(localized: "app_error_speechServiceNotExist")
        case .aiServiceNotExist:
            return String(localized: "app_error_aiServiceNotExist")
        case .noPermissionToSaveImage:
            return String(localized: "app_error_noPermissionToSaveImage")
        case .invalidImageToSave:
            return String(localized: "app_error_invalidImageToSave")
        case .savingImageIsInterrupted:
            return String(localized: "app_error_savingImageIsInterrupted")
        case let .invalidAIAPISettings(message):
            return message
        case let .aiServiceRateLimitExceeded(message):
            return message
        case .aiServiceError:
            return String(localized: "app_error_aiServiceError")
        case .aiServiceInvalidURL:
            return String(localized: "app_error_aiServiceInvalidURL")
        case let .unknown(message):
            return message
        case let .unknownSpeechRecognitionError(message):
            let baseString = String(localized: "app_error_unknownSpeechRecognition")
            return "\(baseString) \(message)"
        case let .unknownImageSaveServiceError(message):
            let baseString = String(localized: "app_error_unknownImageSave")
            return "\(baseString) \(message)"
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }

    static func map(_ error: ConfigurationError) -> Self {
        switch error {
        case .aiConfigurationMissing:
            return .aiConfigurationInvalid
        case .speechConfigurationMissing:
            return .speechConfigurationInvalid
        case .speechConfigurationInvalid:
            return .speechConfigurationInvalid
        case .configurationInvalid:
            return .configurationInvalid
        case .aiConfigurationInvalid:
            return .speechConfigurationInvalid
        default:
            return .configurationFailed(error.localizedDescription)
        }
    }

    static func map(_ error: ImageSaveServiceError) -> Self {
        switch error {
        case .invalidImageToSave:
            return .invalidImageToSave
        case .savingIsInterrupted:
            return .savingImageIsInterrupted
        case .noPermission:
            return .noPermissionToSaveImage
        case .unknownError:
            return .unknownImageSaveServiceError(error.localizedDescription)
        }
    }

    static func map(_ error: SpeechRecognitionError) -> Self {
        .unknownSpeechRecognitionError(error.localizedDescription)
    }

    static func map(_ error: ImageGenerationError) -> Self {
        switch error {
        case .invalidAPIKey, .unauthorized, .accessRestricted:
            return .invalidAIAPISettings(error.localizedDescription)
        case .rateLimitExceeded:
            return .aiServiceRateLimitExceeded(error.localizedDescription)
        case .networkError, .invalidResponse, .noImageData:
            return .aiServiceError
        case .invalidURL:
            return .aiServiceInvalidURL
        case .serverError:
            return .aiServiceError
        }
    }
}

// MARK: - Error Mapping Extension

extension Error {
    /// Maps any generic Error into a formal AppError for UI representation.
    var asAppError: AppError {
        // 1. If it's already an AppError, return it directly
        if let appError = self as? AppError {
            return appError
        }

        // 2. Map specific domain errors (like ConfigurationError)
        if let configError = self as? ConfigurationError {
            return AppError.map(configError)
        }

        if let speechError = self as? SpeechRecognitionError {
            return AppError.map(speechError)
        }

        if let saveError = self as? ImageSaveServiceError {
            return AppError.map(saveError)
        }

        if let generationError = self as? ImageGenerationError {
            return AppError.map(generationError)
        }

        // 3. Fallback for unexpected or generic errors
        return .unknown(localizedDescription)
    }

    var asKidFriendlyError: KidFriendlyError {
        if let kidError = self as? KidFriendlyError { return kidError }

        // Get the technical "Parent" version of the error
        let technicalRoot = asAppError

        // Map specific types to the KidFriendly cases, passing the root along
        if let saveError = self as? ImageSaveServiceError {
            return saveError == .noPermission
                ? .needsParentsHelp(technicalRoot)
                : .cantSavePicture(technicalRoot)
        }

        if let speechError = self as? SpeechRecognitionError {
            switch speechError {
            case .notAuthorized, .recognizerUnavailable:
                return .microphoneOff(technicalRoot)
            case .noResultsReturned:
                return .noSpeechDetected
            default:
                return .generic
            }
        }

        if let imageGenError = self as? ImageGenerationError {
            switch imageGenError {
            case .unauthorized, .invalidAPIKey, .accessRestricted:
                return .needsParentsHelp(technicalRoot)
            case .rateLimitExceeded:
                return .tryAgainLater
            default:
                return .aiServiceDown
            }
        }

        // Fallback for technical config errors
        if self is AppError || self is ConfigurationError {
            return .configurationInvalid(technicalRoot)
        }

        return .generic
    }
}
