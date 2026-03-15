//
//  SpeechRecognitionViewModel.swift
//  ColorBotKids
//
//  Created by ksurikova on 18.02.2026.
//
import Combine
import SwiftUI

enum TTSWarning: Equatable {
    case volumeLow(VolumeWarningLevel)
    case failedToPlay
}

extension TTSWarning {
    var bannerConfig: (icon: String, message: String) {
        switch self {
        case let .volumeLow(level):
            return level.bannerConfig
        case .failedToPlay:
            return (
                "speaker.slash.fill",
                NSLocalizedString("tts_error_failedToPlay", comment: "TTSWarning")
            )
        }
    }
}

@MainActor
final class SpeechRecognitionViewModel: ObservableObject {
    @Published var state: MainActionState = .preparingServices

    @Published var showSettings = false {
        didSet {
            // Persist UI state immediately when it changes
            // This is lightweight and safe for UI flags
            UserDefaults.standard.set(showSettings, forKey: AppConstants.isSettingsPresentedKey)
        }
    }

    @Published var ttsWarning: TTSWarning?

    private var serviceNeedsRecreation = false
    private var cancellables = Set<AnyCancellable>()

    // Accessors for the services safely
    var speechService: SpeechRecognitionService? { servicesManager.services?.speechRecognition }
    var ttsService: TextToSpeechService? { servicesManager.services?.textToSpeech }
    var imageService: ImageGenerationService? { servicesManager.services?.imageGeneration }

    private let servicesManager: MainServicesManager
    private let sessionManager: SessionManager

    var canSpeakText: Bool {
        ttsService != nil && state.isSpeechRecognized
    }

    init(servicesManager: MainServicesManager, sessionManager: SessionManager) {
        self.servicesManager = servicesManager
        self.sessionManager = sessionManager

        // Restore settings state
        showSettings = UserDefaults.standard.bool(forKey: AppConstants.isSettingsPresentedKey)

        // Observe and persist settings state
        $showSettings
            .dropFirst() // Skip the initial value to avoid rewriting immediately
            .sink { isPresented in
                UserDefaults.standard.set(isPresented, forKey: AppConstants.isSettingsPresentedKey)
            }
            .store(in: &cancellables)

        // sign up for configuration changing
        servicesManager.configurationManager.configurationSaved
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.serviceNeedsRecreation = true
            }
            .store(in: &cancellables)
        // Start the lifecycle
        prepare()
    }

    func prepare() {
        do {
            try servicesManager.prepareServices()
            configureTTSCallbacks()
            state = .waiting
        } catch let error as AppError {
            state = .fatalError(error)
        } catch {
            state = .fatalError(.serviceCreationFailed(error.localizedDescription))
        }
    }

    private func configureTTSCallbacks() {
        servicesManager.configureTTSCallbacks(
            onVolumeWarning: { [weak self] level in
                self?.ttsWarning = .volumeLow(level)
            },
            onDidFailToPlay: { [weak self] in
                self?.ttsWarning = .failedToPlay
            }
        )
    }

    func toggleRecording() async {
        guard state.canToggleRecognition else { return }

        // Use the services from the model safely
        guard let speechService = speechService else {
            state =
                .fatalError(
                    .serviceCreationFailed(String(localized: "speech_error_servicesMissing"))
                )
            return
        }

        // we need to handle: .waiting, .processingSpeech, .speechRecognized, .error
        if state == .processingSpeech {
            state = .analysingSpeech
            do {
                let text = try await speechService.stopRecognition()
                guard !text.isEmpty else {
                    state = .error(String(localized: "speech_error_noSpeechDetected"))
                    return
                }
                state = .speechRecognized(text)
                if servicesManager.configurationManager.autoPlayConfirmation {
                    speakCurrentText()
                }
            } catch {
                state = .error(Helpers.formatError(error))
            }
        } else {
            do {
                state = .processingSpeech
                try speechService.startRecognition()
            } catch {
                state = .error(Helpers.formatError(error))
            }
        }
    }

    func generateImage() async {
        guard let prompt = state.recognizedText else { return }
        // Use the services from the model safely
        guard let imageService = imageService else {
            state =
                .fatalError(
                    .serviceCreationFailed(String(localized: "speech_error_servicesMissing"))
                )
            return
        }
        // if we have it, let's stop
        ttsService?.stop()
        state = .generatingImage(from: prompt)

        do {
            let image = try await imageService.generateImage(from: prompt)
            // This triggers the Router to move to .imageEditor because Router observes
            // sessionManager
            sessionManager.start(with: image)
            state = .waiting
        } catch {
            state = .error(Helpers.formatError(error))
        }
    }

    func speakCurrentText() {
        guard let text = state.speechText, let ttsService else {
            assertionFailure("speakCurrentText called without TTS or recognized text")
            return
        }
        ttsService.speakSafely(text)
    }

    func dismissTTSWarning() {
        ttsWarning = nil
    }

    func clearError() {
        if case .error = state { state = .waiting }
    }

    func handleSettingsDismissed() {
        guard serviceNeedsRecreation else { return }
        serviceNeedsRecreation = false
        // Safety: Stop everything before recreation
        speechService?.cancelRecognition()
        ttsService?.stop()
        state = .preparingServices
        do {
            try servicesManager.recreateServices()
            configureTTSCallbacks()
            state = .waiting
        } catch let error as AppError {
            state = .fatalError(error)
        } catch {
            state = .fatalError(.serviceCreationFailed(error.localizedDescription))
        }
    }
}
