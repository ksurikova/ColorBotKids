//
//  MockPermissionService.swift
//  ColorBotKids
//
//  Created by ksurikova on 4.11.2025.
//
import SwiftUI

class MockPermissionService: PermissionService {
    // Predefined results for checking
    var permissionStatuses: [String: PermissionStatus]
    var grantResults: [String: Bool]

    // Simulate delay
    var simulateDelay: Bool
    var delayNanoseconds: UInt64

    // MARK: - Initializer

    init(
        permissionStatuses: [String: PermissionStatus] = [
            "microphone": .notDetermined,
            "speechRecognition": .notDetermined,
            "photoLibrary": .notDetermined,
        ],
        grantResults: [String: Bool] = [
            "microphone": true,
            "speechRecognition": true,
            "photoLibrary": true,
        ],
        simulateDelay: Bool = true,
        delayNanoseconds: UInt64 = 1_000_000_000
    ) {
        self.permissionStatuses = permissionStatuses
        self.grantResults = grantResults
        self.simulateDelay = simulateDelay
        self.delayNanoseconds = delayNanoseconds
    }

    func checkPermission(for type: any PermissionDefinition) -> PermissionStatus {
        permissionStatuses[type.id] ?? .notDetermined
    }

    func grantPermission(for type: any PermissionDefinition) async -> Bool {
        if simulateDelay {
            try? await Task.sleep(nanoseconds: delayNanoseconds)
        }

        let result = grantResults[type.id] ?? false

        // Update status if grant succeeds
        if result {
            permissionStatuses[type.id] = .authorized
        }

        return result
    }

    func setStatus(_ status: PermissionStatus, for permissionId: String) {
        permissionStatuses[permissionId] = status
    }

    func setGrantResult(_ result: Bool, for permissionId: String) {
        grantResults[permissionId] = result
    }

    func setAllStatuses(_ status: PermissionStatus) {
        for key in permissionStatuses.keys {
            permissionStatuses[key] = status
        }
    }
}

private struct PermissionServiceKey: EnvironmentKey {
    static let defaultValue: PermissionService = DefaultPermissionService()
}

extension EnvironmentValues {
    var permissionService: PermissionService {
        get { self[PermissionServiceKey.self] }
        set { self[PermissionServiceKey.self] = newValue }
    }
}
