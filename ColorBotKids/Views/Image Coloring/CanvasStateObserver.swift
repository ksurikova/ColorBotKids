//
//  CanvasStateObserver.swift
//  ColorBotKids
//
//  Created by ksurikova on 14.11.2025.
//
import Combine
import PencilKit

final class CanvasStateObserver: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let canvasView: PKCanvasView
    @Published private(set) var currentState = DrawingState()

    init(canvasView: PKCanvasView) {
        self.canvasView = canvasView
        setupObservers()
    }

    private func setupObservers() {
        NotificationCenter.default.publisher(for: .NSUndoManagerDidUndoChange)
            .merge(with: NotificationCenter.default.publisher(for: .NSUndoManagerDidRedoChange))
            .merge(with: NotificationCenter.default
                .publisher(for: .NSUndoManagerWillCloseUndoGroup))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateState()
            }
            .store(in: &cancellables)
    }

    private func updateState() {
        currentState = DrawingState(
            canUndo: canvasView.undoManager?.canUndo ?? false,
            canRedo: canvasView.undoManager?.canRedo ?? false,
            hasContent: !canvasView.drawing.bounds.isEmpty
        )
    }

    func forceRefresh() {
        updateState()
    }

    deinit {
        cancellables.removeAll()
    }
}
