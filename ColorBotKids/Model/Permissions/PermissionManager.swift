//
//  PermissionManager.swift
//  ColorBotKids
//
//  Created by ksurikova on 05.01.2026.
//
import Combine

final class PermissionManager {
    // CurrentValueSubject holds the state AND notifies listeners
    let microphone = CurrentValueSubject<PermissionStatus, Never>(.notDetermined)
    let speechRecognition = CurrentValueSubject<PermissionStatus, Never>(.notDetermined)
    let photoLibrary = CurrentValueSubject<PermissionStatus, Never>(.notDetermined)

    private let service: PermissionService
    init(service: PermissionService) { self.service = service }

    // MARK: - Public Helpers

    var hasAllRequiredPermissions: Bool {
        Permissions.all
            .filter(\.isRequired)
            .allSatisfy { permission in
                getPermissionStatus(permission).isAuthorized
            }
    }

    var hasSpeechPermissions: Bool {
        microphone.value.isAuthorized && speechRecognition.value.isAuthorized
    }

    var hasPhotoPermission: Bool {
        photoLibrary.value.isAuthorized
    }

    func request(_ permission: any PermissionDefinition) async -> Bool {
        let granted = await service.grantPermission(for: permission)
        let status = service.checkPermission(for: permission)

        // Updating the .value automatically notifies all subscribers
        updateInternalState(for: permission, status: status)
        return granted
    }

    private func updateInternalState(
        for permission: any PermissionDefinition,
        status: PermissionStatus
    ) {
        switch permission.id {
        case Permissions.microphone.id: microphone.send(status)
        case Permissions.speechRecognition.id: speechRecognition.send(status)
        case Permissions.photoLibrary.id: photoLibrary.send(status)
        default: break
        }
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

    func checkAll() {
        for permission in Permissions.all {
            let status = service.checkPermission(for: permission)
            updateInternalState(for: permission, status: status)
        }
        print("✅ Permissions checked")
    }
}
