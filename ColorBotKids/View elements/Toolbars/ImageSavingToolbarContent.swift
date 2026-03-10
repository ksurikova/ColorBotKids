//
//  SaveActionToolbarContent.swift
//  ColorBotKids
//
//  Created by ksurikova on 25.11.2025.
//
import SwiftUI

struct ImageSavingToolbarContent: ToolbarContent {
    let photoLibraryStatus: PermissionStatus
    let isSaving: Bool
    let onSave: () -> Void
    let onGoToSettings: () -> Void

    var body: some ToolbarContent {
        if photoLibraryStatus == .authorized {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onSave) {
                    Image(systemName: "square.and.arrow.down.fill")
                }
                .buttonStyle(.toolbar(color: .green))
                .disabled(isSaving)
            }
        }
        if photoLibraryStatus == .denied {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("common_action_allow", action: onGoToSettings)
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .controlSize(.small)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onSave) {
                    Image(systemName: "square.and.arrow.down.fill")
                }
                .buttonStyle(.toolbar(color: .green))
                .disabled(true)
            }
        }
        // Restricted/not determined → no buttons
    }
}

#Preview("denied") {
    NavigationStack {
        Text("Test")
            .toolbar {
                ImageSavingToolbarContent(
                    photoLibraryStatus: .denied,
                    isSaving: false,
                    onSave: {},
                    onGoToSettings: {}
                )
            }
    }
}

#Preview("allow") {
    NavigationStack {
        Text("Test")
            .toolbar {
                ImageSavingToolbarContent(
                    photoLibraryStatus: .authorized,
                    isSaving: false,
                    onSave: {},
                    onGoToSettings: {}
                )
            }
    }
}
