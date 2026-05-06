//
//  StubPermissionManager.swift
//  ColorBotKids
//
//  Created by GitHub Copilot on 06.05.2026.
//

import Combine
import Foundation

final class StubPermissionManager: PermissionManaging {
    var microphone: CurrentValueSubject<PermissionStatus, Never>
    var speechRecognition: CurrentValueSubject<PermissionStatus, Never>
    var photoLibrary: CurrentValueSubject<PermissionStatus, Never>

    var hasAllRequiredPermissions: Bool
    var hasSpeechPermissions: Bool

    init(
        microphoneStatus: PermissionStatus = .authorized,
        speechRecognitionStatus: PermissionStatus = .authorized,
        photoLibraryStatus: PermissionStatus = .authorized,
        hasAllRequiredPermissions: Bool = true,
        hasSpeechPermissions: Bool = true
    ) {
        microphone = .init(microphoneStatus)
        speechRecognition = .init(speechRecognitionStatus)
        photoLibrary = .init(photoLibraryStatus)
        self.hasAllRequiredPermissions = hasAllRequiredPermissions
        self.hasSpeechPermissions = hasSpeechPermissions
    }

    func request(_ permission: any PermissionDefinition) async -> Bool {
        return true
    }

    func getPermissionStatus(_ permission: any PermissionDefinition) -> PermissionStatus {
        switch permission.id {
        case Permissions.microphone.id:
            return microphone.value
        case Permissions.speechRecognition.id:
            return speechRecognition.value
        case Permissions.photoLibrary.id:
            return photoLibrary.value
        default:
            return .notDetermined
        }
    }

    func checkAll() {}
}
