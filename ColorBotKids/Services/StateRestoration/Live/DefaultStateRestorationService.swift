//
//  DefaultStateRestorationService.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.12.2025.
//
import Foundation
import PencilKit
import SwiftUI

class DefaultStateRestorationService: StateRestorationService {
    private var sessionsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("DrawingSessions")
    }

    private func imageURL(for stateURL: URL) -> URL {
        stateURL.appendingPathComponent("image.png")
    }

    private func drawingURL(for stateURL: URL) -> URL {
        stateURL.appendingPathComponent("drawing.pk")
    }

    init() {
        try? FileManager.default.createDirectory(
            at: sessionsDirectory,
            withIntermediateDirectories: true
        )
    }

    func loadState(from url: URL) -> (image: UIImage, drawingData: Data)? {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }

        guard let image = UIImage(contentsOfFile: imageURL(for: url).path),
              let drawingData = try? Data(contentsOf: drawingURL(for: url)) else {
            return nil
        }

        return (image, drawingData)
    }

    func clearState(at url: URL?) {
        guard let url = url else { return }
        try? FileManager.default.removeItem(at: url)
    }

    func saveState(image: UIImage, drawingData: Data) throws -> URL {
        guard let imageData = image.pngData() else {
            throw StateRestorationError.encodingError("Failed to get PNG data")
        }

        let stateID = UUID().uuidString
        let stateURL = sessionsDirectory.appendingPathComponent(stateID)

        try FileManager.default.createDirectory(
            at: stateURL,
            withIntermediateDirectories: true
        )
        try imageData.write(to: imageURL(for: stateURL), options: .atomic)
        try drawingData.write(to: drawingURL(for: stateURL), options: .atomic)

        return stateURL
    }
}
