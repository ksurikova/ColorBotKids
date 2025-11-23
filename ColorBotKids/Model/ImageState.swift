//
//  ImageState.swift
//  ColorBotKids
//
//  Created by ksurikova on 25.10.2025.
//
enum ImageState: Equatable {
    case idle
    case unsavedChanges
    case saving
    case failed(ImageSaveServiceError)

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.unsavedChanges, .unsavedChanges),
             (.saving, .saving):
            return true
        case let (.failed(lhsError), .failed(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }

    var isSaving: Bool { self == .saving }
    var hasUnsavedChanges: Bool { self == .unsavedChanges }

    var errorMessage: String? {
        if case let .failed(error) = self {
            return error.localizedDescription
        }
        return nil
    }
}

struct DrawingState: Equatable {
    var canUndo: Bool = false
    var canRedo: Bool = false
    var hasContent: Bool = false

    var hasChanges: Bool {
        hasContent
    }
}
