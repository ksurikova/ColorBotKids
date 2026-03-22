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
    let permissionManager: PermissionManager
    let draftService: SpeechConfigurationDraftService

    init(
        configManager: ConfigurationManager,
        permissionManager: PermissionManager,
        draftService: SpeechConfigurationDraftService
    ) {
        self.permissionManager = permissionManager
        self.draftService = draftService
        _viewModel = StateObject(wrappedValue: SettingsViewModel(
            configManager: configManager,
            permissionManager: permissionManager,
            draftService: draftService
        ))
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
                        permissionManager: permissionManager
                    )
                }
            }
            .navigationTitle("common_title_settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common_action_cancel") {
                        viewModel.discardChanges()
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
    }
}
