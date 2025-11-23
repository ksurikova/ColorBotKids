//
//  ImageEditorView.swift
//  ColorBotKids
//
//  Created by ksurikova on 25.10.2025.
//
import Combine
import PencilKit
import SwiftUI

struct ImageEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appModel: AppModel
    @Environment(\.drawService) private var drawService
    @Environment(\.imageSaveService) private var imageSaveService

    @State private var image: UIImage
    @State private var canvasView: PKCanvasView
    @State private var imageState: ImageState = .idle {
        didSet {
            if imageState == .idle {
                showSuccessBanner = true
            }
        }
    }

    @State private var showExitConfirmation = false
    @State private var showSuccessBanner = false

    @StateObject private var observer: CanvasStateObserver
    @State private var toolPickerManager: ToolPickerManager?

    init(image: UIImage) {
        _image = State(initialValue: image)

        let canvas = PKCanvasView()
        _canvasView = State(initialValue: canvas)

        _observer = StateObject(wrappedValue: CanvasStateObserver(canvasView: canvas))
    }

    private var drawingState: DrawingState {
        observer.currentState
    }

    private var isSavingImage: Bool {
        imageState == .saving
    }

    private var canSave: Bool {
        appModel.photoLibraryStatus == .authorized && !imageState.isSaving
    }

    var body: some View {
        ZStack {
            ColoringView(
                image: image,
                canvasView: canvasView,
                drawingState: drawingState,
                canSave: canSave,
                onBackPressed: handleBackPressed,
                onSavePressed: handleSavePressed,
                onUndo: undo,
                onRedo: redo
            )
            if isSavingImage {
                DimmerBackgroundView()
                ProgressIndicatorView(descriptionMessage: "Saving your image...")
            }
        }
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .top) {
            if let error = imageState.errorMessage {
                ErrorBannerView(message: error) {
                    self.imageState = .idle
                }
                .padding(.top, 60)
            } else if showSuccessBanner {
                SuccessBannerView(
                    message: "Great job! Your drawing is saved! 🎨",
                    onClose: {
                        showSuccessBanner = false
                    }
                )
                .padding(.top, 60)
            }
        }
        .onChange(of: observer.currentState) { _, newState in
            handleDrawingStateChange(newState)
        }
        .onChange(of: showExitConfirmation) { _, newValue in
            // Hide/show tool picker when sheet appears/disappears
            if newValue {
                toolPickerManager?.hide()
            } else {
                toolPickerManager?.show()
            }
        }
        .onAppear {
            // Initialize tool picker manager after view appears
            // (canvasView needs to be in window hierarchy)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if toolPickerManager == nil {
                    toolPickerManager = ToolPickerManager(canvasView: canvasView)
                }
            }
        }
        .sheet(isPresented: $showExitConfirmation) {
            ExitConfirmationView(
                onSaveAndExit: {
                    Task {
                        await performSave()
                        dismiss()
                    }
                },
                onExitWithoutSaving: {
                    dismiss()
                },
                onCancel: {
                    showExitConfirmation = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    private func handleDrawingStateChange(_ newState: DrawingState) {
        if newState.hasChanges, imageState == .idle {
            imageState = .unsavedChanges
        } else if !newState.hasChanges, imageState == .unsavedChanges {
            imageState = .idle
        }
    }

    func undo() {
        canvasView.undoManager?.undo()
    }

    func redo() {
        canvasView.undoManager?.redo()
    }

    private func reset(with newImage: UIImage) {
        image = newImage
        canvasView.undoManager?.removeAllActions()
        observer.forceRefresh()
    }

    // MARK: - Action Handlers

    private func handleBackPressed() {
        if imageState == .unsavedChanges {
            showExitConfirmation = true
        } else {
            dismiss()
        }
    }

    private func handleSavePressed() {
        Task {
            print("we are in save method")
            await performSave()
        }
    }

    @MainActor
    private func performSave() async {
        do {
            imageState = .saving
            let finalImage = drawService.combineImageWithDrawing(image, canvasView: canvasView)
            try await imageSaveService.saveImageToPhotoLibrary(finalImage)
            reset(with: finalImage)
            imageState = .idle
        } catch {
            let editorError = error as? ImageSaveServiceError ?? .unknownError(error)
            imageState = .failed(editorError)
        }
    }
}

#Preview {
    NavigationStack {
        ImageEditorView(
            image: UIImage(named: "defaultImage")!
        ).environmentObject(AppModel.mockFullyConfigured())
    }
}
