//
//  ToolPickerManager.swift
//  ColorBotKids
//
//  Created by ksurikova on 16.11.2025.
//
import PencilKit

final class ToolPickerManager {
    private weak var canvasView: PKCanvasView?
    private var toolPicker: PKToolPicker?

    init(canvasView: PKCanvasView) {
        self.canvasView = canvasView
        findToolPicker()
    }

    private func findToolPicker() {
        guard let window = canvasView?.window else { return }
        toolPicker = PKToolPicker.shared(for: window)
    }

    func hide() {
        guard let canvasView = canvasView else { return }

        // Refresh reference if needed
        if toolPicker == nil {
            findToolPicker()
        }

        toolPicker?.setVisible(false, forFirstResponder: canvasView)
    }

    func show() {
        guard let canvasView = canvasView else { return }

        // Refresh reference if needed
        if toolPicker == nil {
            findToolPicker()
        }

        toolPicker?.setVisible(true, forFirstResponder: canvasView)
    }
}
