//
//  PermissionStatus.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.12.2025.
//
enum PermissionStatus {
    case notDetermined
    case authorized
    case denied
    case restricted

    var isAuthorized: Bool {
        self == .authorized
    }

    var needsSettings: Bool {
        self == .denied
    }
}

protocol PermissionDefinition: Hashable {
    var id: String { get }
    var isRequired: Bool { get }
}

struct AnyPermission: PermissionDefinition, Hashable {
    let id: String
    let isRequired: Bool

    init(_ permission: any PermissionDefinition) {
        id = permission.id
        isRequired = permission.isRequired
    }
}

enum Permissions {
    static let microphone = MicrophonePermission.shared
    static let speechRecognition = SpeechRecognitionPermission.shared
    static let photoLibrary = PhotoLibraryPermission.shared

    static let all: [any PermissionDefinition] = [
        microphone,
        speechRecognition,
        photoLibrary,
    ]

    static let speechPermissions: [any PermissionViewRepresentable] = [
        microphone,
        speechRecognition,
    ]
}
