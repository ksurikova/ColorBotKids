//
//  SessionManager.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.02.2026.
//
import Combine
import SwiftUI

final class SessionManager {
    let sessionChanged = PassthroughSubject<Void, Never>()
    private(set) var currentSession: DrawingSession?

    private let stateStorage: StateStorage
    private let restorationService: StateRestorationService

    init(
        stateStorage: StateStorage,
        restorationService: StateRestorationService
    ) {
        self.stateStorage = stateStorage
        self.restorationService = restorationService
    }

    // MARK: - Public Interface

    var hasActiveSession: Bool {
        currentSession != nil
    }

    func start(with image: UIImage) {
        currentSession = DrawingSession(image: image)
        sessionChanged.send() // Trigger
    }

    func updateDrawing(_ data: Data) {
        guard var session = currentSession else {
            print("No active session to update")
            return
        }

        session.drawingData = data
        session.lastModified = Date()
        currentSession = session
        sessionChanged.send() // Trigger
    }

    func save() throws {
        guard let session = currentSession else {
            throw SessionError.noActiveSession
        }

        guard let drawingData = session.drawingData else {
            throw SessionError.noDrawingData
        }

        let url = try restorationService.saveState(
            image: session.image,
            drawingData: drawingData
        )

        stateStorage.setCurrentStateURL(url)

        var updated = session
        updated.persistenceURL = url
        currentSession = updated
        sessionChanged.send() // Trigger
    }

    func clear() {
        currentSession = nil
        stateStorage.setCurrentStateURL(nil)
        sessionChanged.send() // Trigger
    }

    func delete() throws {
        guard let session = currentSession else { return }

        if let url = session.persistenceURL {
            restorationService.clearState(at: url)
        }

        clear()
    }

    func restoreLast() {
        guard let url = stateStorage.getCurrentStateURL() else {
            print("No session to restore")
            return
        }

        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Stale session reference, clearing")
            stateStorage.setCurrentStateURL(nil)
            return
        }

        if let (image, drawingData) = restorationService.loadState(from: url) {
            currentSession = DrawingSession(
                image: image,
                drawingData: drawingData,
                persistenceURL: url
            )
        } else {
            print("Restoration failed, cleaning up")
            restorationService.clearState(at: url)
            stateStorage.setCurrentStateURL(nil)
        }
        sessionChanged.send() // Trigger
    }
}
