//
//  EditorPersistenceInteractor.swift
//  ColorBotKids
//
//  Created by ksurikova on 06.03.2026.
//

import Combine
import PencilKit
import SwiftUI

// Handles loading, saving, and persisting the current drawing session.
@MainActor
final class EditorPersistenceInteractor {
    private let sessionManager: SessionManager

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }

    // Returns the initial image for the editing session.
    var initialImage: UIImage? {
        sessionManager.currentSession?.image
    }

    // Loads the existing drawing data from the session.
    func loadDrawingData() -> Data? {
        sessionManager.currentSession?.drawingData
    }

    // Updates the in-memory session and triggers disk persistence.
    func saveDrawingState(_ data: Data) {
        // Update the model
        sessionManager.updateDrawing(data)

        // Persist to disk asynchronously
        do {
            try sessionManager.save()
        } catch {
            print("⚠️ Failed to auto-save session: \(error)")
        }
    }

    // Clears the active session when editing is finished.
    func clearSession() {
        sessionManager.clear()
    }

    // Validates session existence
    var hasActiveSession: Bool {
        sessionManager.currentSession != nil
    }
}
