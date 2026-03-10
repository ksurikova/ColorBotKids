//
//  SpeechPermissionsViewModel.swift
//  ColorBotKids
//
//  Created by ksurikova on 3.03.2026.
//
import Combine
import SwiftUI

@MainActor
final class SpeechPermissionsViewModel: ObservableObject {
    @Published private(set) var micStatus: PermissionStatus
    @Published private(set) var speechStatus: PermissionStatus

    private let manager: PermissionManager
    private var cancellables = Set<AnyCancellable>()

    init(manager: PermissionManager) {
        self.manager = manager
        micStatus = manager.microphone.value
        speechStatus = manager.speechRecognition.value

        // Listen to BOTH permissions
        Publishers.CombineLatest(manager.microphone, manager.speechRecognition)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mic, speech in
                self?.micStatus = mic
                self?.speechStatus = speech
            }
            .store(in: &cancellables)
    }

    func request(_ permission: any PermissionDefinition) async -> Bool {
        await manager.request(permission)
    }
}
