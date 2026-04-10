//
//  ImageState.swift
//  ColorBotKids
//
//  Created by ksurikova on 25.10.2025.
//
import SwiftUI

enum ImageState: Equatable {
    case idle
    case unsavedChanges
    case saving
    case failed(KidFriendlyError)

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.unsavedChanges, .unsavedChanges),
             (.saving, .saving):
            return true
        case let (.failed(lhsError), .failed(rhsError)):
            return lhsError == rhsError
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
