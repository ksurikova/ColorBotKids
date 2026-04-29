//
//  SettingsView.swift
//  ColorBotKids
//
//  Created by ksurikova on 24.11.2025.
//
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                ConfigurationContainerView(
                    error: viewModel.error.map { $0 as Error },
                    onDismissError: viewModel.dismissError
                ) {
                    AIConfigurationSectionView(
                        viewModel: viewModel.aiViewModel
                    )

                    SpeechConfigurationSectionView(
                        viewModel: viewModel.speechViewModel
                    )

                    PermissionsPhotoSectionView(
                        viewModel: viewModel.photoViewModel
                    )
                }
            }
            .navigationTitle("common_title_settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common_action_cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Button("common_action_save") {
                            viewModel.save()
                            if viewModel.error == nil {
                                dismiss()
                            }
                        }
                        .disabled(!viewModel.canSave)
                    }
                }
            }
        }
        .onDisappear {
            // Ensure any unsaved drafts are cleared when the sheet is dismissed
            // (e.g. by swipe gesture), matching "Cancel" button behavior.
            viewModel.discardChanges()
        }
    }
}
