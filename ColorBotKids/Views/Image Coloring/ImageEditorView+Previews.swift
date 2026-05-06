//
//  ImageEditorView+Previews.swift
//  ColorBotKids
//
//  Created by GitHub Copilot on 06.05.2026.
//

import SwiftUI

struct ImageEditorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 1. Happy Path - Editing an image
            previewFor(state: .happyPath, name: "Happy Path")

            // 2. Missing Photo Permissions
            previewFor(state: .missingPermissions, name: "Missing Photo Permission")
        }
    }

    enum PreviewState {
        case happyPath
        case missingPermissions
    }

    @MainActor
    private static func previewFor(state: PreviewState, name: String) -> some View {
        let dummyImage = UIImage(systemName: "star.fill") ?? UIImage()
        let dummySession = DrawingSession(image: dummyImage)

        let sessionManager = StubSessionManager(
            currentSession: dummySession,
            hasActiveSession: true
        )
        let permissionManager = StubPermissionManager(
            photoLibraryStatus: state == .missingPermissions ? .denied : .authorized
        )
        let toolingManager = StubImageToolingManager()

        let viewModel = ImageEditorViewModel(
            sessionManager: sessionManager,
            toolingManager: toolingManager,
            permissionManager: permissionManager,
            settingsService: MockSettingsService()
        )

        return ImageEditorView(viewModel: viewModel)
            .previewDisplayName(name)
    }
}
