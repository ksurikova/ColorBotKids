//
//  DrawingSession.swift
//  ColorBotKids
//
//  Created by ksurikova on 4.02.2026.
//

import Foundation
import SwiftUI

struct DrawingSession: Identifiable, Equatable, Hashable {
    let id: UUID
    var image: UIImage
    var drawingData: Data?
    let createdAt: Date
    var lastModified: Date
    var persistenceURL: URL?

    init(
        id: UUID = UUID(),
        image: UIImage,
        drawingData: Data? = nil,
        createdAt: Date = Date(),
        lastModified: Date = Date(),
        persistenceURL: URL? = nil
    ) {
        self.id = id
        self.image = image
        self.drawingData = drawingData
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.persistenceURL = persistenceURL
    }

    // Equatable conformance (UIImage comparison is tricky, so we use reference equality)
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id &&
            lhs.image === rhs.image &&
            lhs.drawingData == rhs.drawingData &&
            lhs.persistenceURL == rhs.persistenceURL
    }
}
