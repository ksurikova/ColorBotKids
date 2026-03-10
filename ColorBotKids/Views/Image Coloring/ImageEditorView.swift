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
    @Environment(\.scenePhase) private var scenePhase

    @ObservedObject private var viewModel: ImageEditorViewModel

    init(viewModel: ImageEditorViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ImageEditorContentView(viewModel: viewModel)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                viewModel.setupToolPicker()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .inactive || newPhase == .background {
                    viewModel.saveStateIfNeeded()
                }
            }
            .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
                if shouldDismiss {
                    viewModel.finishSession()
                    dismiss()
                }
            }
    }
}
