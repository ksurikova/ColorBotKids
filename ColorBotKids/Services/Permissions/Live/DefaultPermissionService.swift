//
//  PermissionService.swift
//  ColorBotKids
//
//  Created by ksurikova on 17.10.2025.
//
import AVFoundation
import Photos
import Speech
import SwiftUI

class DefaultPermissionService: PermissionService {
    func checkPermission(for type: any PermissionDefinition) -> PermissionStatus {
        switch type.id {
        case Permissions.microphone.id:
            return getMicrophonePermissionStatus()
        case Permissions.photoLibrary.id:
            return getSaveToPhotoLibraryPermissionStatus()
        case Permissions.speechRecognition.id:
            return getSpeechRecognizingPermissionStatus()
        default:
            return .notDetermined
        }
    }

    func grantPermission(for type: any PermissionDefinition) async -> Bool {
        switch type.id {
        case Permissions.microphone.id:
            return await grantMicrophoneAuthorization()
        case Permissions.photoLibrary.id:
            return await grantPhotoLibraryPermission()
        case Permissions.speechRecognition.id:
            return await grantSpeechAuthorization()
        default:
            return false
        }
    }

    func getMicrophonePermissionStatus() -> PermissionStatus {
        let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        return Self.evaluate(from: micStatus)
    }

    private static func evaluate(from microphoneStatus: AVAuthorizationStatus) -> PermissionStatus {
        switch microphoneStatus {
        case .authorized:
            return .authorized
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        default:
            return .notDetermined
        }
    }

    func getSpeechRecognizingPermissionStatus() -> PermissionStatus {
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        return Self.evaluate(from: speechStatus)
    }

    private static func evaluate(from speechStatus: SFSpeechRecognizerAuthorizationStatus)
        -> PermissionStatus {
        switch speechStatus {
        case .authorized:
            return .authorized
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        default:
            return .notDetermined
        }
    }

    func getSaveToPhotoLibraryPermissionStatus() -> PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        return Self.evaluate(from: status)
    }

    private static func evaluate(from status: PHAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .authorized:
            return .authorized
        case .limited:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .notDetermined
        }
    }

    private func grantPhotoLibraryPermission() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        return Self.evaluate(from: status).isAuthorized
    }

    private func grantSpeechAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation
                    .resume(returning: Self.evaluate(from: status).isAuthorized)
            }
        }
    }

    private func grantMicrophoneAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
