//
//  MockStateRestorationService.swift
//  ColorBotKids
//
//  Created by ksurikova on 4.12.2025.
//
import PencilKit
import SwiftUI
import UIKit

class MockStateRestorationService: StateRestorationService {
    var shouldFailSave = false
    var shouldFailLoad = false
    var saveErrorToThrow: StateRestorationError?

    var savedImage: UIImage?
    var savedDrawing: Data?
    var savedStateURL: URL?
    var loadedURL: URL?
    var clearedURL: URL?

    var mockLoadImage: UIImage?
    var mockLoadDrawingData: Data?

    // MARK: - StateRestorationService Implementation

    func saveState(image: UIImage, drawingData: Data) throws -> URL {
        savedImage = image
        savedDrawing = drawingData

        if shouldFailSave {
            throw saveErrorToThrow ?? StateRestorationError.fileError("Mock save failure")
        }

        let mockURL = URL(fileURLWithPath: "/mock/state/\(UUID().uuidString)")
        savedStateURL = mockURL
        return mockURL
    }

    func loadState(from url: URL) -> (image: UIImage, drawingData: Data)? {
        loadedURL = url

        if shouldFailLoad {
            return nil
        }

        guard let image = mockLoadImage,
              let drawingData = mockLoadDrawingData else {
            return nil
        }

        return (image, drawingData)
    }

    func clearState(at url: URL?) {
        clearedURL = url
    }

    func setupSuccessfulLoad(image: UIImage, drawing: PKDrawing) {
        mockLoadImage = image
        mockLoadDrawingData = drawing.dataRepresentation()
        shouldFailLoad = false
    }
}

extension MockStateRestorationService {
    static var empty: MockStateRestorationService {
        MockStateRestorationService()
    }

    static var successfulSave: MockStateRestorationService {
        let mock = MockStateRestorationService()
        mock.shouldFailSave = false
        return mock
    }

    static var failedSave: MockStateRestorationService {
        let mock = MockStateRestorationService()
        mock.shouldFailSave = true
        mock.saveErrorToThrow = .fileError("Mock save failure")
        return mock
    }

    static var successfulLoad: MockStateRestorationService {
        let mock = MockStateRestorationService()
        mock.shouldFailLoad = false
        mock.mockLoadImage = createTestImage()
        mock.mockLoadDrawingData = createTestDrawing().dataRepresentation()
        return mock
    }

    static var failedLoad: MockStateRestorationService {
        let mock = MockStateRestorationService()
        mock.shouldFailLoad = true
        return mock
    }

    static var withSavedState: MockStateRestorationService {
        let mock = MockStateRestorationService()
        mock.savedStateURL = URL(fileURLWithPath: "/tmp/preview-state")
        mock.savedImage = createTestImage()
        mock.savedDrawing = createTestDrawing().dataRepresentation()
        return mock
    }

    static func createTestImage() -> UIImage {
        UIImage(named: "defaultImage")!
    }

    static func createTestDrawing() -> PKDrawing {
        PKDrawing()
    }
}
