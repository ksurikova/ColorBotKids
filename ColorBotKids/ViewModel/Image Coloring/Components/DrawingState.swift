//
//  DrawingState.swift
//  ColorBotKids
//
//  Created by ksurikova on 18.03.2026.
//
struct DrawingState: Equatable {
    var canUndo: Bool = false
    var canRedo: Bool = false
    var hasContent: Bool = false

    var hasChanges: Bool {
        hasContent
    }
}
