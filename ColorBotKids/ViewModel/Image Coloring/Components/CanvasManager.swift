//
//  CanvasManager.swift
//  ColorBotKids
//
//  Created by ksurikova on 28.02.2026.
//

import Combine
import PencilKit
import SwiftUI

@MainActor
final class CanvasManager: ObservableObject {
    @Published var canvasView = PKCanvasView()
    @Published private(set) var drawingState = DrawingState()

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupObservers()
    }

    // MARK: - Canvas Control

    func undo() {
        canvasView.undoManager?.undo()
    }

    func redo() {
        canvasView.undoManager?.redo()
    }

    func clear() {
        canvasView.drawing = PKDrawing()
        updateDrawingState()
    }

    func load(data: Data) {
        // Try to load, fallback to empty
        if let drawing = try? PKDrawing(data: data) {
            canvasView.drawing = drawing
        } else {
            canvasView.drawing = PKDrawing()
        }
        updateDrawingState()
    }

    func getCurrentData() -> Data {
        canvasView.drawing.dataRepresentation()
    }

    // MARK: - Internal Observers

    private func setupObservers() {
        NotificationCenter.default.publisher(for: .NSUndoManagerDidUndoChange)
            .merge(with: NotificationCenter.default.publisher(for: .NSUndoManagerDidRedoChange))
            .merge(with: NotificationCenter.default
                .publisher(for: .NSUndoManagerWillCloseUndoGroup))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateDrawingState()
            }
            .store(in: &cancellables)
    }

    private func updateDrawingState() {
        drawingState = DrawingState(
            canUndo: canvasView.undoManager?.canUndo ?? false,
            canRedo: canvasView.undoManager?.canRedo ?? false,
            hasContent: !canvasView.drawing.bounds.isEmpty
        )
    }
}
