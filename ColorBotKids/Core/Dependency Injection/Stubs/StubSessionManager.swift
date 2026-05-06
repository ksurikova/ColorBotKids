//
//  StubSessionManager.swift
//  ColorBotKids
//
//  Created by GitHub Copilot on 06.05.2026.
//

import Combine
import Foundation
import UIKit

final class StubSessionManager: SessionManaging {
    var sessionChanged: PassthroughSubject<Void, Never> = .init()
    var currentSession: DrawingSession?
    var hasActiveSession: Bool

    init(currentSession: DrawingSession? = nil, hasActiveSession: Bool = false) {
        self.currentSession = currentSession
        self.hasActiveSession = hasActiveSession
    }

    func start(with image: UIImage) {}
    func updateDrawing(_ data: Data) {}
    func save() throws {}
    func clear() {}
    func delete() throws {}
    func restoreLast() {}
}
