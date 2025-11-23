//
//  DrawingCanvasContainerView.swift
//  ColorBotKids
//
//  Created by ksurikova on 25.10.2025.
//
import PencilKit
import Photos
import PhotosUI
import SwiftUI

class CanvasHostingViewController: UIViewController {
    var externalUndoManager: UndoManager?

    override var undoManager: UndoManager? {
        externalUndoManager ?? super.undoManager
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}

struct DrawingCanvasContainerView: UIViewControllerRepresentable {
    @Binding var canvasView: PKCanvasView
    var existingDrawingData: Data?
    var displaySize: CGSize
    @Environment(\.undoManager) private var envUndoManager

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = CanvasHostingViewController()
        viewController.externalUndoManager = envUndoManager

        viewController.view.backgroundColor = .clear
        viewController.view.frame.size = displaySize

        canvasView.drawingPolicy = .anyInput
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.frame = CGRect(origin: .zero, size: displaySize)
        canvasView.delegate = context.coordinator

        if let data = existingDrawingData,
           let drawing = try? PKDrawing(data: data) {
            canvasView.drawing = drawing
        }

        // Store references in coordinator
        context.coordinator.canvasView = canvasView
        context.coordinator.viewController = viewController

        setupToolPicker(for: canvasView, coordinator: context.coordinator)

        viewController.view.addSubview(canvasView)

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        canvasView.frame = CGRect(origin: .zero, size: displaySize)
        uiViewController.view.frame.size = displaySize
    }

    static func dismantleUIViewController(
        _ uiViewController: UIViewController,
        coordinator: Coordinator
    ) {
        if let toolPicker = coordinator.toolPicker, let canvasView = coordinator.canvasView {
            toolPicker.setVisible(false, forFirstResponder: canvasView)
            toolPicker.removeObserver(coordinator)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func setupToolPicker(for canvas: PKCanvasView, coordinator: Coordinator) {
        // Try immediate setup
        if let window = canvas.window,

           // MARK: it is deprecated, but other ways do not work

           let toolPicker = PKToolPicker.shared(for: window) {
            configureToolPicker(toolPicker, for: canvas, coordinator: coordinator)
        }
        // Backup delayed setup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let window = canvas.window,
                  let toolPicker = PKToolPicker.shared(for: window)
            else {
                // MARK: todo fatal error?

                print("❌ No window/tool picker available")
                return
            }
            configureToolPicker(toolPicker, for: canvas, coordinator: coordinator)
        }
    }

    private func configureToolPicker(
        _ toolPicker: PKToolPicker,
        for canvas: PKCanvasView,
        coordinator: Coordinator
    ) {
        coordinator.toolPicker = toolPicker
        canvas.becomeFirstResponder()
        toolPicker.addObserver(coordinator)
        toolPicker.setVisible(true, forFirstResponder: canvas)
        canvas.tool = toolPicker.selectedTool
    }

    class Coordinator: NSObject, PKToolPickerObserver, PKCanvasViewDelegate {
        var canvasView: PKCanvasView?
        var toolPicker: PKToolPicker?
        var viewController: CanvasHostingViewController?

        // MARK: it is deprecated, but other ways do not work

        func toolPickerSelectedToolDidChange(_ toolPicker: PKToolPicker) {
            canvasView?.tool = toolPicker.selectedTool
        }

        func toolPickerIsRulerActiveDidChange(_ toolPicker: PKToolPicker) {
            canvasView?.isRulerActive = toolPicker.isRulerActive
        }

        // This delegate method is called when drawing changes
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // You can add logic here to track drawing state changes
            // For example, update UI based on whether there's content to undo
        }

        deinit {
            toolPicker?.removeObserver(self)
        }
    }
}
