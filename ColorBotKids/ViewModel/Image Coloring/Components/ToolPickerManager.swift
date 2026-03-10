//
//  ToolPickerManager.swift
//  ColorBotKids
//
//  Created by ksurikova on 25.02.2026.
//

import PencilKit
import UIKit

@MainActor
final class ToolPickerManager {
    private weak var canvasView: PKCanvasView?
    private var toolPicker: PKToolPicker?

    init(canvasView: PKCanvasView) {
        self.canvasView = canvasView
    }

    // Sets up the tool picker. Must be called when the canvas view is in the window hierarchy
    // (e.g. onAppear).
    func setup() {
        guard let canvasView = canvasView, let window = canvasView.window else { return }

        toolPicker = PKToolPicker.shared(for: window)
        toolPicker?.addObserver(canvasView)
        toolPicker?.setVisible(true, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()
    }

    func setVisible(_ visible: Bool) {
        guard let canvasView = canvasView else { return }

        // Lazy loading if not setup yet, provided window is available
        if toolPicker == nil {
            setup()
        }

        toolPicker?.setVisible(visible, forFirstResponder: canvasView)

        if visible {
            canvasView.becomeFirstResponder()
        } else {
            canvasView.resignFirstResponder()
        }
    }
}
