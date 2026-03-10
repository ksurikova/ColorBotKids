//
//  PermissionViewRepresentable.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.12.2025.
//
protocol PermissionViewRepresentable: PermissionDefinition {
    var icon: String { get }
    var titleKey: String { get }
    var descriptionKey: String { get }
}

extension PermissionViewRepresentable {
    var title: String { String(localized: .init(titleKey)) }
    var description: String { String(localized: .init(descriptionKey)) }
}

struct MicrophonePermission: PermissionViewRepresentable {
    let id = "microphone"
    let isRequired = true
    let icon = "mic.fill"
    let titleKey = "permission_title_microphone"
    let descriptionKey = "permission_description_microphone"

    static let shared = Self()
}

struct SpeechRecognitionPermission: PermissionViewRepresentable {
    let id = "speechRecognition"
    let isRequired = true
    let icon = "text.bubble.fill"
    let titleKey = "permission_title_speech"
    let descriptionKey = "permission_description_speech"

    static let shared = Self()
}

struct PhotoLibraryPermission: PermissionViewRepresentable {
    let id = "photoLibrary"
    let isRequired = false
    let icon = "photo.fill"
    let titleKey = "permission_title_photoLibrary"
    let descriptionKey = "permission_description_photoLibrary"

    static let shared = Self()
}
