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
        do {
            try FileManager.default.createDirectory(
                at: sessionsDirectory,
                withIntermediateDirectories: true
            )
        } catch {
            // Log the specific file system error for developer diagnostics
            print("Failed to create base sessions directory: \(error.localizedDescription)")
        }
    }

    func loadState(from url: URL) throws -> (image: UIImage, drawingData: Data) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw StateRestorationError.fileNotFound
        }

        guard let image = UIImage(contentsOfFile: imageURL(for: url).path) else {
            throw StateRestorationError.decodingFailed
        }

        let drawingData: Data
        do {
            drawingData = try Data(contentsOf: drawingURL(for: url))
        } catch {
            throw StateRestorationError.decodingFailed
        }

        return (image, drawingData)
    }

    func clearState(at url: URL?) {
        guard let url = url else { return }
        try? FileManager.default.removeItem(at: url)
    }

    func saveState(image: UIImage, drawingData: Data) throws -> URL {
        guard let imageData = image.pngData() else {
            throw StateRestorationError.imageEncodingFailed
        }

        let stateID = UUID().uuidString
        let stateURL = sessionsDirectory.appendingPathComponent(stateID)

        do {
            try FileManager.default.createDirectory(
                at: stateURL,
                withIntermediateDirectories: true
            )
        } catch {
            throw StateRestorationError.directoryCreationFailed
        }

        do {
            try imageData.write(to: imageURL(for: stateURL), options: .atomic)
        } catch {
            throw StateRestorationError.imageWriteFailed
        }

        do {
            try drawingData.write(to: drawingURL(for: stateURL), options: .atomic)
        } catch {
            throw StateRestorationError.drawingWriteFailed
        }

        return stateURL
    }
}
