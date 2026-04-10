//
//  ImageEditorContentView.swift
//  ColorBotKids
//
//  Created by ksurikova on 19.12.2025.
//
import Combine
import PencilKit
import SwiftUI

struct ImageEditorContentView: View {
    @ObservedObject var viewModel: ImageEditorViewModel

    var body: some View {
        ZStack {
            ColoringView(
                image: viewModel.image,
                canvasView: viewModel.canvasManager.canvasView,
                drawingState: viewModel.canvasManager.drawingState,
                onBackPressed: viewModel.handleBack,
                onUndo: viewModel.undo,
                onRedo: viewModel.redo
            )
            .toolbar {
                ImageSavingToolbarContent(
                    photoLibraryStatus: viewModel.photoLibraryStatus,
                    isSaving: viewModel.imageState.isSaving,
                    onSave: { Task { await viewModel.saveImage() } },
                    onGoToSettings: {
                        viewModel.saveStateIfNeeded()
                        viewModel.openSettings(
                            willOpen: {},
                            completion: { success in
                                if !success {
                                    viewModel.showSettingsAlert = true
                                }
                            }
                        )
                    }
                )
            }

            if viewModel.imageState.isSaving {
                DimmerBackgroundView()
                ProgressIndicatorView(
                    descriptionMessage: String(localized: "color_message_savingImage")
                )
            }
        }
        .overlay(alignment: .top) {
            StatusBanners(
                errorMessage: viewModel.errorMessage,
                showSuccess: viewModel.showSuccessBanner,
                onDismissError: { viewModel.clearError() },
                onDismissSuccess: { viewModel.showSuccessBanner = false }
            )
        }
        .sheet(isPresented: $viewModel.showExitConfirmation) {
            ExitConfirmationSheet(
                onSaveAndExit: viewModel.saveAndExit,
                onExitWithoutSaving: viewModel.exitWithoutSaving,
                onCancel: { viewModel.showExitConfirmation = false }
            )
        }
        .onChange(of: viewModel.showExitConfirmation) { _, showing in
            viewModel.setToolPickerVisible(!showing)
        }
        .onDisappear {
            viewModel.setToolPickerVisible(false)
        }
    }
}

private extension ImageEditorContentView {
    struct ExitConfirmationSheet: View {
        let onSaveAndExit: () -> Void
        let onExitWithoutSaving: () -> Void
        let onCancel: () -> Void

        var body: some View {
            ExitConfirmationView(
                onSaveAndExit: onSaveAndExit,
                onExitWithoutSaving: onExitWithoutSaving,
                onCancel: onCancel
            )
        }
    }

    struct StatusBanners: View {
        let errorMessage: String?
        let showSuccess: Bool
        let onDismissError: () -> Void
        let onDismissSuccess: () -> Void

        var body: some View {
            VStack {
                if let error = errorMessage {
                    ErrorBannerView(message: error, action: onDismissError)
                        .transition(.move(edge: .top).combined(with: .opacity))
                } else if showSuccess {
                    SuccessBannerView(
                        message: String.localized("color_message_successSaving"),
                        onClose: onDismissSuccess
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.top, 60) // Safe area padding
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: errorMessage != nil)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSuccess)
            // Auto-dismiss the success banner after 3 seconds
            .task(id: showSuccess) {
                if showSuccess {
                    try? await Task.sleep(for: .seconds(3))
                    withAnimation {
                        onDismissSuccess()
                    }
                }
            }
        }
    }
}
