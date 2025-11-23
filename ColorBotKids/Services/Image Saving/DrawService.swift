//
//  DrawServiceProtocol.swift
//  ColorBotKids
//
//  Created by ksurikova on 13.11.2025.
//
import PencilKit
import SwiftUI

protocol DrawService {
    func combineImageWithDrawing(_ image: UIImage, canvasView: PKCanvasView) -> UIImage
}

final class MockDrawService: DrawService {
    func combineImageWithDrawing(_ image: UIImage, canvasView: PKCanvasView) -> UIImage {
        image
    }
}

private struct DrawServiceKey: EnvironmentKey {
    static let defaultValue: DrawService = MockDrawService()
}

extension EnvironmentValues {
    var drawService: DrawService {
        get { self[DrawServiceKey.self] }
        set { self[DrawServiceKey.self] = newValue }
    }
}
