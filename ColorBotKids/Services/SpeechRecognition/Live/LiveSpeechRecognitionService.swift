//
//  LiveSpeechRecognitionService.swift
//  ColorBotKids
//
//  Created by ksurikova on 23.10.2025.
//
import AVFoundation
import Foundation
import Speech

final class LiveSpeechRecognitionService: NSObject, SpeechRecognitionService,
    SFSpeechRecognizerDelegate {
    func getCurrentLocale() -> Locale {
        settings.locale
    }

    private let audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode?
    private var speechRecognizer: SFSpeechRecognizer
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var settings: SpeechRecognitionSettings
    private(set) var isRunning: Bool = false
    private var recognitionContinuation: CheckedContinuation<String, Error>?

    // CriticalServiceCapability conforming
    static func canRunApp() -> Bool {
        !getSupportedLocales().isEmpty
    }

    static func unavailabilityMessage() -> String? {
        guard !canRunApp() else { return nil }
        return String(localized: "speech_error_unavailabilityMessage")
    }

    static func getSupportedLocales() -> [Locale] {
        SFSpeechRecognizer.supportedLocales()
            .sorted { $0.identifier < $1.identifier }
    }

    init(settings: SpeechRecognitionSettings) throws {
        guard let recognizer = SFSpeechRecognizer(locale: settings.locale) else {
            throw SpeechRecognitionError
                .initializationFailed(SpeechRecognitionError.recognizerNotSupported)
        }

        // Check on-device support if required
        if settings.requiresOnDevice, !recognizer.supportsOnDeviceRecognition {
            throw
                SpeechRecognitionError
                .initializationFailed(SpeechRecognitionError.recognizerNotSupported)
        }

        speechRecognizer = recognizer
        self.settings = settings
        super.init()
        speechRecognizer.delegate = self
    }

    static func canCreateWithCurrentSettings(_ settings: SpeechRecognitionSettings) -> Bool {
        guard let recognizer = SFSpeechRecognizer(locale: settings.locale) else {
            return false
        }
        // Check on-device support if required
        if settings.requiresOnDevice && !recognizer.supportsOnDeviceRecognition {
            return false
        } else {
            return true
        }
    }

    func startRecognition() throws {
        guard !isRunning else {
            throw SpeechRecognitionError.alreadyRunning
        }

        do {
            try checkAuthorization()
            try configureAudioSession()
            try validateRecognizerAvailability()
            try setupRecognitionRequest()
            try setupAudioEngine()
            startRecognitionTask()

            isRunning = true
        } catch {
            cleanup()
            throw error
        }
    }

    private func checkAuthorization() throws {
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        guard authStatus == .authorized else {
            throw SpeechRecognitionError.notAuthorized
        }
    }

    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func validateRecognizerAvailability() throws {
        guard speechRecognizer.isAvailable else {
            throw SpeechRecognitionError.recognizerUnavailable
        }
    }

    private func setupAudioEngine() throws {
        inputNode = audioEngine.inputNode
        guard let inputNode else {
            throw SpeechRecognitionError.audioConversionFailed
        }

        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    private func setupRecognitionRequest() throws {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else {
            throw SpeechRecognitionError.recognitionFailed(NSError(domain: "", code: -1))
        }

        recognitionRequest.shouldReportPartialResults = settings.shouldReportPartialResults
        recognitionRequest.requiresOnDeviceRecognition = settings.requiresOnDevice
    }

    private func startRecognitionTask() {
        guard let recognitionRequest else { return }

        recognitionTask = speechRecognizer
            .recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self else { return }

                if let error = error {
                    self.handleRecognitionError(error)
                    return
                }

                if let result = result, result.isFinal {
                    let best = result.bestTranscription.formattedString
                    self.completeRecognition(with: best)
                }
            }
    }

    private func finishRecognition() {
        recognitionRequest?.endAudio()
        audioEngine.stop()
        inputNode?.removeTap(onBus: 0)
    }

    private func completeRecognition(with transcription: String) {
        cleanup()
        if transcription.isEmpty {
            recognitionContinuation?.resume(throwing: SpeechRecognitionError.noResultsReturned)
        } else {
            recognitionContinuation?.resume(returning: transcription)
        }
        recognitionContinuation = nil
    }

    private func handleRecognitionError(_ error: Error) {
        cleanup()
        recognitionContinuation?.resume(throwing: SpeechRecognitionError.recognitionFailed(error))
        recognitionContinuation = nil
    }

    private func cleanup() {
        isRunning = false
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        inputNode = nil
    }

    func stopRecognition() async throws -> String {
        print("we tap stop")
        guard isRunning else {
            throw SpeechRecognitionError.notRunning
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.recognitionContinuation = continuation
            self.finishRecognition()
        }
    }

    func speechRecognizer(
        _ speechRecognizer: SFSpeechRecognizer,
        availabilityDidChange available: Bool
    ) {
        if !available, isRunning {
            handleRecognitionError(SpeechRecognitionError.recognizerUnavailable)
        }
    }
}
