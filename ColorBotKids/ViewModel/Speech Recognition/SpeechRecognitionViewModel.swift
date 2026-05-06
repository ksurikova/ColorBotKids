//
//  SpeechRecognitionViewModel.swift
//  ColorBotKids
//
//  Created by ksurikova on 18.02.2026.
//
import Combine
import SwiftUI

enum TTSWarning: Equatable, Identifiable {
    case volumeLow(VolumeWarningLevel, id: UUID = UUID())
    case failedToPlay(id: UUID = UUID())

    var id: UUID {
        switch self {
        case let .volumeLow(_, id): return id
        case let .failedToPlay(id): return id
        }
    }
}

extension TTSWarning {
    var bannerConfig: (icon: String, message: String) {
        switch self {
        case let .volumeLow(level, _):
            return level.bannerConfig
        case .failedToPlay:
            return (
                "speaker.slash.fill",
                String(localized: "kid_error_failed_to_play")
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

    @Published var showRecordingHint = false
    @Published var ttsWarning: TTSWarning?

    private var cancellables = Set<AnyCancellable>()
    private var hintTask: Task<Void, Never>?

    // Accessors for the services safely
    var speechService: SpeechRecognitionService? { servicesManager.services?.speechRecognition }
    var ttsService: TextToSpeechService? { servicesManager.services?.textToSpeech }
    var imageService: ImageGenerationService? { servicesManager.services?.imageGeneration }

    private let servicesManager: MainServicesManaging
    private let sessionManager: SessionManaging

    var canSpeakText: Bool {
        ttsService != nil && state.isSpeechRecognized
    }

    init(servicesManager: MainServicesManaging, sessionManager: SessionManaging) {
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

        // Observe state changes to manage the Hint logic
        $state
            .removeDuplicates()
            .sink { [weak self] newState in
                self?.manageHintVisibility(for: newState)
            }
            .store(in: &cancellables)

        // Start the lifecycle
        prepare()
    }

    private func manageHintVisibility(for newState: MainActionState) {
        // Cancel any existing timer
        hintTask?.cancel()

        if newState == .processingSpeech {
            // Reset immediately
            showRecordingHint = false

            // Start 3-second timer
            hintTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)

                // Ensure task wasn't cancelled and state hasn't changed
                if !Task.isCancelled && state == .processingSpeech {
                    withAnimation(.spring()) {
                        self.showRecordingHint = true
                    }
                }
            }
        } else {
            // Hide immediately for all other states
            withAnimation {
                showRecordingHint = false
            }
        }
    }

    func prepare() {
        do {
            try servicesManager.prepareServices()
            configureTTSCallbacks()
            state = .waiting
        } catch {
            state = .fatalError(error.asKidFriendlyError)
        }
    }

    private func configureTTSCallbacks() {
        servicesManager.configureTTSCallbacks(
            onVolumeWarning: { [weak self] level in
                self?.ttsWarning = .volumeLow(level)
            },
            onDidFailToPlay: { [weak self] in
                self?.ttsWarning = .failedToPlay()
            }
        )
    }

    func toggleRecording() async {
        guard let speechService else {
            state = .fatalError(.needsParentsHelp(AppError.speechServiceNotExist))
            return
        }

        if state == .processingSpeech {
            state = .analysingSpeech
            do {
                let text = try await speechService.stopRecognition(progressHandler: nil)
                guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    state = .temporaryError(
                        .noSpeechDetected,
                        prompt: nil
                    )
                    return
                }
                state = .speechRecognized(text)
            } catch {
                state = .temporaryError(error.asKidFriendlyError, prompt: nil)
            }
        } else {
            do {
                try speechService.startRecognition()
                state = .processingSpeech
            } catch {
                state = .temporaryError(
                    error.asKidFriendlyError,
                    prompt: state.recognizedText
                )
            }
        }
    }

    func generateImage() async {
        guard let prompt = state.recognizedText else { return }
        // Use the services from the model safely
        guard let imageService = imageService else {
            state = .fatalError(.needsParentsHelp(AppError.aiServiceNotExist))
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
        } catch let error as ImageGenerationError {
            switch error {
            case .unauthorized, .accessRestricted, .invalidAPIKey:
                state = .configurationRequired(
                    .needsParentsHelp(error.asAppError),
                    prompt: prompt
                )
            case .rateLimitExceeded:
                state = .temporaryError(
                    .tryAgainLater,
                    prompt: prompt
                )
            default:
                state = .temporaryError(error.asKidFriendlyError, prompt: prompt)
            }
        } catch {
            state = .temporaryError(error.asKidFriendlyError, prompt: prompt)
        }
    }

    func clearError() {
        // If the user dismisses the error banner, we want to return to the recognized state
        // if we have a valid prompt, so they don't lose their text.
        switch state {
        case let .temporaryError(_, prompt), let .configurationRequired(_, prompt):
            if let text = prompt {
                state = .speechRecognized(text)
            } else {
                state = .waiting
            }
        default:
            if state.errorMessage != nil {
                state = .waiting
            }
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

    func handleSettingsDismissed() {
        // Capture relevant state before potential reset
        let promptToRestore = state.recognizedText
        let wasConfigurationRequired = state.configurationRequiredMessage != nil

        // If services returned to nil (invalidated by Manager due to config change), we must
        // rebuild them
        if servicesManager.services == nil {
            prepare()
        }

        // If we were blocked by configuration, and coming back from settings,
        // we restore the "Recognized" state (Draw button enabled) so the user can try again.
        if wasConfigurationRequired, let prompt = promptToRestore {
            // Only restore if we are in a safe state (e.g., waiting after prepare, or still in
            // config error)
            // We don't want to override a fatal error if prepare() failed.
            switch state {
            case .waiting, .configurationRequired:
                state = .speechRecognized(prompt)
            default:
                break
            }
        }
    }
}
