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

    private let teardownLock = NSLock()
    private var isTornDown = false
    private var installedInputNode: AVAudioInputNode?
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
            throw SpeechRecognitionError.initializationFailed
        }
        if settings.requiresOnDevice, !recognizer.supportsOnDeviceRecognition {
            throw SpeechRecognitionError.initializationFailed
        }
        speechRecognizer = recognizer
        self.settings = settings
        super.init()
        speechRecognizer.delegate = self
    }

    // MARK: - Static Helpers

    static func getSupportedLocales() -> [Locale] {
        SFSpeechRecognizer.supportedLocales().sorted { $0.identifier < $1.identifier }
    }

    static func canCreateWithCurrentSettings(_ settings: SpeechRecognitionSettings) -> Bool {
        guard let recognizer = SFSpeechRecognizer(locale: settings.locale) else { return false }
        return settings.requiresOnDevice ? recognizer.supportsOnDeviceRecognition : true
    }

    func getCurrentLocale() -> Locale { settings.locale }

    func getExecutionTimeout() -> TimeInterval {
        settings.speechTimeout
    }

    // MARK: - Start

    func startRecognition() throws {
        guard !isRunning else { throw SpeechRecognitionError.alreadyRunning }

        // Reset teardown state for subsequent uses
        teardownLock.lock()
        isTornDown = false
        teardownLock.unlock()

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

    func stopRecognition(progressHandler: ((Double) -> Void)?) async throws -> String {
        guard isRunning else { throw SpeechRecognitionError.notRunning }

        // Signal the end of audio BEFORE waiting, so the recognizer finalizes
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()

        return try await withThrowingTaskGroup(of: String.self) { group in
            group.addTask {
                try await self.waitForFinalResult()
            }

            group.addTask {
                let timeoutSeconds = Int(self.settings.speechTimeout)
                for i in 0 ..< timeoutSeconds {
                    progressHandler?(Double(timeoutSeconds - i))
                    try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                }
                progressHandler?(0)
                throw SpeechRecognitionError.timeout
            }

            do {
                let result = try await group.next()
                group.cancelAll()
                return result ?? ""
            } catch SpeechRecognitionError.timeout {
                group.cancelAll()
                self.cancelRecognition()
                throw SpeechRecognitionError.timeout
            } catch {
                group.cancelAll()
                throw error
            }
        }
    }

    // Safer continuation capture
    private func waitForFinalResult() async throws -> String {
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                self.teardownLock.lock()
                // Safely assign continuation under lock so teardown can't miss it
                self.recognitionContinuation = continuation
                self.teardownLock.unlock()
            }
        } onCancel: {
            self.cancelRecognition()
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

        // It is best practice to explicitly remove any lingering tap before installing a new one
        inputNode.removeTap(onBus: 0)

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
                    self.teardown(resumingWith: .failure(SpeechRecognitionError.recognitionFailed))
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
    func teardown(resumingWith result: Result<String, Error>?) {
        let continuationToResume: CheckedContinuation<String, Error>?

        teardownLock.lock()

        guard !isTornDown else {
            teardownLock.unlock()
            return
        }
        isTornDown = true

        if audioEngine.isRunning {
            audioEngine.stop()
        }

        // Remove tap directly from the audio engine node, not the optional
        audioEngine.inputNode.removeTap(onBus: 0)
        installedInputNode = nil

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        recognitionTask?.cancel()
        recognitionTask = nil

        isRunning = false

        try? configureAudioSession(active: false)

        continuationToResume = recognitionContinuation
        recognitionContinuation = nil

        teardownLock.unlock()

        // Resume the continuation OUTSIDE the lock
        if let result {
            continuationToResume?.resume(with: result)
        }
    }
}
