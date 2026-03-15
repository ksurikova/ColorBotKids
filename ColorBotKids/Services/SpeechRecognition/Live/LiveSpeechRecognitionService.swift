//
//  LiveSpeechRecognitionService.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.03.2025.
//
import AVFoundation
import Foundation
import Speech

final class LiveSpeechRecognitionService: NSObject, SpeechRecognitionService,
    SFSpeechRecognizerDelegate {
    // MARK: - Private State

    private let audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var settings: SpeechRecognitionSettings

    // to prevent calling teardown multiple times concurrently
    private let teardownLock = NSLock()
    private var isTornDown = false

    // Retained only while the audio tap is installed.
    private var installedInputNode: AVAudioInputNode?

    // Guarded by main actor or a serial queue — see note below.
    private var recognitionContinuation: CheckedContinuation<String, Error>?

    private(set) var isRunning: Bool = false

    // MARK: - CriticalServiceCapability

    static func canRunApp() -> Bool {
        !getSupportedLocales().isEmpty
    }

    static func unavailabilityMessage() -> String? {
        guard !canRunApp() else { return nil }
        return String(localized: "speech_error_unavailabilityMessage")
    }

    // MARK: - Init

    init(settings: SpeechRecognitionSettings) throws {
        guard let recognizer = SFSpeechRecognizer(locale: settings.locale) else {
            throw SpeechRecognitionError
                .initializationFailed(SpeechRecognitionError.recognizerNotSupported)
        }
        if settings.requiresOnDevice, !recognizer.supportsOnDeviceRecognition {
            throw SpeechRecognitionError
                .initializationFailed(SpeechRecognitionError.recognizerNotSupported)
        }
        speechRecognizer = recognizer
        self.settings = settings
        super.init()
        speechRecognizer.delegate = self
    }

    // MARK: - Static Helpers

    static func getSupportedLocales() -> [Locale] {
        SFSpeechRecognizer.supportedLocales()
            .sorted { $0.identifier < $1.identifier }
    }

    static func canCreateWithCurrentSettings(_ settings: SpeechRecognitionSettings) -> Bool {
        guard let recognizer = SFSpeechRecognizer(locale: settings.locale) else { return false }
        return settings.requiresOnDevice ? recognizer.supportsOnDeviceRecognition : true
    }

    func getCurrentLocale() -> Locale {
        settings.locale
    }

    // MARK: - Start

    func startRecognition() throws {
        guard !isRunning else {
            throw SpeechRecognitionError.alreadyRunning
        }
        do {
            try checkAuthorization()
            try configureAudioSession(active: true)
            try validateRecognizerAvailability()
            try setupRecognitionRequest()
            try setupAudioEngine()
            startRecognitionTask()
            isRunning = true
        } catch {
            teardown(resumingWith: nil)
            throw error
        }
    }

    // MARK: - Stop (cooperative — waits for final result)

    func stopRecognition() async throws -> String {
        guard isRunning else {
            throw SpeechRecognitionError.notRunning
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.recognitionContinuation = continuation
            // Signal end of audio — recognition task will deliver the final result
            // via the completion handler, which resumes the continuation.
            self.recognitionRequest?.endAudio()
            self.audioEngine.stop()
            self.installedInputNode?.removeTap(onBus: 0)
            self.installedInputNode = nil
        }
    }

    // MARK: - Cancel (immediate — no result)

    func cancelRecognition() {
        guard isRunning else { return }
        teardown(resumingWith: .failure(SpeechRecognitionError.cancelled))
    }

    // MARK: - SFSpeechRecognizerDelegate

    func speechRecognizer(
        _ speechRecognizer: SFSpeechRecognizer,
        availabilityDidChange available: Bool
    ) {
        guard !available, isRunning else { return }
        teardown(resumingWith: .failure(SpeechRecognitionError.recognizerUnavailable))
    }
}

// MARK: - Private Setup

private extension LiveSpeechRecognitionService {
    func checkAuthorization() throws {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            throw SpeechRecognitionError.notAuthorized
        }
    }

    func configureAudioSession(active: Bool) throws {
        let session = AVAudioSession.sharedInstance()
        if active {
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        }
        try session.setActive(active, options: .notifyOthersOnDeactivation)
    }

    func validateRecognizerAvailability() throws {
        guard speechRecognizer.isAvailable else {
            throw SpeechRecognitionError.recognizerUnavailable
        }
    }

    func setupRecognitionRequest() throws {
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = settings.shouldReportPartialResults
        request.requiresOnDeviceRecognition = settings.requiresOnDevice
        recognitionRequest = request
    }

    func setupAudioEngine() throws {
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        installedInputNode = inputNode
        audioEngine.prepare()
        try audioEngine.start()
    }

    func startRecognitionTask() {
        guard let request = recognitionRequest else { return }

        recognitionTask = speechRecognizer
            .recognitionTask(with: request) { [weak self] result, error in
                guard let self else { return }

                if let error {
                    self
                        .teardown(resumingWith: .failure(SpeechRecognitionError
                                .recognitionFailed(error)))
                    return
                }

                if let result, result.isFinal {
                    let transcription = result.bestTranscription.formattedString
                    let outcome: Result<String, Error> = transcription.isEmpty
                        ? .failure(SpeechRecognitionError.noResultsReturned)
                        : .success(transcription)
                    self.teardown(resumingWith: outcome)
                }
            }
    }
}

// MARK: - Private Teardown

private extension LiveSpeechRecognitionService {
    // Single path for all cleanup. Resumes the pending continuation if one exists.
    // Pass `nil` only when tearing down mid-start before a continuation was set.
    func teardown(resumingWith result: Result<String, Error>?) {
        teardownLock.lock()
        defer { teardownLock.unlock() }

        guard !isTornDown else { return }
        isTornDown = true
        // Stop audio first, before cancelling the task,
        // so the recognizer can process any buffered audio
        // in the cooperative (stop) path before task cancellation.
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        installedInputNode?.removeTap(onBus: 0)
        installedInputNode = nil

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        recognitionTask?.cancel()
        recognitionTask = nil

        isRunning = false

        // Deactivate audio session — best-effort, non-fatal
        try? configureAudioSession(active: false)

        // Resume the continuation exactly once
        if let result, let continuation = recognitionContinuation {
            recognitionContinuation = nil
            continuation.resume(with: result)
        }
    }
}
