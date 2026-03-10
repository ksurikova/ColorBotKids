//
//  ColoringView.swift
//  ColorBotKids
//
//  Created by ksurikova on 25.10.2025.
//
import PencilKit
import SwiftUI

struct ColoringView: View {
    let image: UIImage
    let canvasView: PKCanvasView
    let drawingState: DrawingState
    var drawingData: Data?

    let onBackPressed: () -> Void
    let onUndo: () -> Void
    let onRedo: () -> Void

    var body: some View {
        ImageCanvasView(
            image: image,
            canvasView: .constant(canvasView),
            drawingData: drawingData
        )
        .padding()
        .toolbar {
            drawingToolbarContent()
        }
    }

    @ToolbarContentBuilder
    private func drawingToolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: onBackPressed) {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.toolbar(color: .orange))
        }

        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button(action: onUndo) {
                Image(systemName: "arrow.uturn.backward")
            }
            .buttonStyle(.toolbar(color: .blue))
            .disabled(!drawingState.canUndo)

            Button(action: onRedo) {
                Image(systemName: "arrow.uturn.forward")
            }
            .buttonStyle(.toolbar(color: .purple))
            .disabled(!drawingState.canRedo)
        }
    }
}

#Preview {
    NavigationStack {
        ColoringView(
            image: UIImage(named: "defaultImage")!,
            canvasView: PKCanvasView(),
            drawingState: DrawingState(),
            onBackPressed: {},
            onUndo: {},
            onRedo: {}
        )
    }
}
