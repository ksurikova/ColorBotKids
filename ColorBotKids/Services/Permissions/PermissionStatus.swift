//
//  PermissionStatus.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.11.2025.
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

// UI permission info (view layer)
protocol PermissionViewRepresentable: PermissionDefinition {
    var icon: String { get }
    var title: String { get }
    var description: String { get }
}

struct MicrophonePermission: PermissionViewRepresentable {
    let id = "microphone"
    let isRequired = true
    let icon = "mic.fill"
    let title = "Microphone"
    let description = "To hear your voice descriptions"

    static let shared = Self()
}

struct SpeechRecognitionPermission: PermissionViewRepresentable {
    let id = "speechRecognition"
    let isRequired = true
    let icon = "text.bubble.fill"
    let title = "Speech Recognition"
    let description = "To convert speech into text prompts"

    static let shared = Self()
}

struct PhotoLibraryPermission: PermissionViewRepresentable {
    let id = "photoLibrary"
    let isRequired = false
    let icon = "photo.fill"
    let title = "Photo Library"
    let description = "To save colored images to your device"

    static let shared = Self()
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
