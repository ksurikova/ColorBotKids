//
//  ImageEditorViewModel.swift
//  ColorBotKids
//
//  Created by ksurikova on 19.12.2025.
//
import Combine
import PencilKit
import SwiftUI

@MainActor
final class ImageEditorViewModel: ObservableObject {
    // MARK: - Published State

    @Published var image: UIImage
    // Canvas logic delegated to manager
    @Published var canvasManager = CanvasManager()

    @Published private(set) var imageState: ImageState = .idle

    @Published var showExitConfirmation = false
    @Published var showSuccessBanner = false
    @Published var showSettingsAlert = false
    @Published var shouldDismiss = false

    // MARK: - Computed Properties

    var photoLibraryStatus: PermissionStatus {
        permissionManager.photoLibrary.value
    }

    var canSaveToLibrary: Bool {
        photoLibraryStatus == .authorized
    }

    var isSaving: Bool {
        imageState.isSaving
    }

    var hasUnsavedChanges: Bool {
        imageState.hasUnsavedChanges
    }

    var errorMessage: String? {
        imageState.errorMessage
    }

    // MARK: - Dependencies

    private let persistenceInteractor: EditorPersistenceInteractor
    private let toolingManager: ImageToolingManager
    private let permissionManager: PermissionManager
    private let settingsService: SettingsService

    // MARK: - Internal State

    private var toolPickerManager: ToolPickerManager
    private var cancellables = Set<AnyCancellable>()

    init(
        persistenceInteractor: EditorPersistenceInteractor,
        toolingManager: ImageToolingManager,
        permissionManager: PermissionManager,
        settingsService: SettingsService
    ) {
        self.persistenceInteractor = persistenceInteractor
        self.toolingManager = toolingManager
        self.permissionManager = permissionManager
        self.settingsService = settingsService

        guard let initialImage = persistenceInteractor.initialImage else {
            fatalError(
                "ImageEditorViewModel initialized without active session. Router must ensure session exists."
            )
        }

        image = initialImage

        // Initialize managers locally
        let cm = CanvasManager()
        canvasManager = cm

        // Initialize tool picker manager with the local canvas reference
        toolPickerManager = ToolPickerManager(canvasView: cm.canvasView)

        // Setup permission monitoring (Forward changes to View)
        permissionManager.photoLibrary
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Observe canvas changes
        cm.$drawingState
            .dropFirst()
            .sink { [weak self] state in
                if state.hasContent {
                    self?.markContentChanged()
                }
                // Forward updates to ViewModel observers if needed
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        loadSessionData()
    }

    // MARK: - User Actions

    func setupToolPicker() {
        toolPickerManager.setup()
    }

    func setToolPickerVisible(_ visible: Bool) {
        toolPickerManager.setVisible(visible)
    }

    func undo() {
        canvasManager.undo()
    }

    func redo() {
        canvasManager.redo()
    }

    func markContentChanged() {
        if imageState != .unsavedChanges, !imageState.isSaving {
            imageState = .unsavedChanges
        }
    }

    func handleBack() {
        if imageState.hasUnsavedChanges, canSaveToLibrary {
            showExitConfirmation = true
        } else {
            exitEditor()
        }
    }

    func exitWithoutSaving() {
        exitEditor()
    }

    func saveAndExit() {
        Task {
            await saveImage()
            // Only exit if save didn't fail
            if case .idle = imageState {
                exitEditor()
            }
        }
    }

    func saveImage() async {
        imageState = .saving

        do {
            _ = try await toolingManager.saveImage(
                baseImage: image,
                canvasView: canvasManager.canvasView
            )
            imageState = .idle
            showSuccessBanner = true
        } catch {
            let saveError = (error as? ImageSaveServiceError) ?? .unknownError(error)
            imageState = .failed(saveError)
        }
    }

    func saveStateIfNeeded() {
        // Update session manager with current drawing data
        let currentDrawingData = canvasManager.getCurrentData()
        persistenceInteractor.saveDrawingState(currentDrawingData)
    }

    func openSettings(willOpen: (() -> Void)?, completion: ((Bool) -> Void)?) {
        settingsService.openAppSettings(willOpen: willOpen, completion: completion)
    }

    func clearError() {
        imageState = .idle
    }

    func finishSession() {
        persistenceInteractor.clearSession()
    }

    // MARK: - Private Helpers

    private func exitEditor() {
        finishSession()
        shouldDismiss = true
    }

    private func loadSessionData() {
        if let data = persistenceInteractor.loadDrawingData() {
            canvasManager.load(data: data)
        } else {
            canvasManager.clear()
        }
    }
}
