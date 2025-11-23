//
//  SpeechView.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//
import SwiftUI

struct SpeechRecognitionView: View {
    @EnvironmentObject var appModel: AppModel
    @Environment(\.speechRecognitionService) private var speechRecognitionService
    @Environment(\.textToSpeechService) private var textToSpeechService
    @Environment(\.imageGenerationService) private var imageGenerationService
    @Environment(\.drawService) private var drawService
    @Environment(\.imageSaveService) private var imageSaveService

    @State private var useOnlyOnDevice = false
    @State private var recognitionState: RecognitionState = .waiting
    @State private var error: Error?
    @State private var showVolumeWarning = false
    @State private var showEditor = false // true if we finished picture generation
    @State private var isGeneratingImage = false // true if picture generation is in process
    @State private var generatedImage: UIImage?

    private var currentPrompt: String {
        switch recognitionState {
        case .waiting:
            return "Tap the microphone\nand tell me what to draw"
        case .processingSpeech:
            return "Listening..."
        case .analysingSpeech:
            return "Analyzing..."
        case let .speechRecognized(text):
            return text
        case .error:
            return ""
        }
    }

    private var showHearButton: Bool {
        recognitionState.isSpeechRecognized
    }

    private var enableDrawButton: Bool {
        recognitionState.isSpeechRecognized
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                VStack(spacing: 32) {
                    Spacer()
                    // Title
                    VStack(spacing: 8) {
                        Text("I want to color")
                            .titleStyle()
                    }
                    .padding(.top, 40)
                    Spacer()

                    VStack {
                        Spacer()
                        if recognitionState.isProcessing {
                            PulsingWaveView(isActive: true)
                                .transition(.scale.combined(with: .opacity))
                        }
                        ModernPromptCard(text: currentPrompt)
                        Spacer()
                    }
                    // "Hear Again" button (appears when speech is recognized)
                    if showHearButton {
                        Button(action: { speakText(currentPrompt) },
                               label: {
                                   HStack(spacing: 6) {
                                       Image(systemName: "speaker.wave.2.fill")
                                           .font(.system(size: 14, weight: .semibold))
                                       Text("Hear Again")
                                           .font(.system(
                                               size: 15,
                                               weight: .semibold,
                                               design: .rounded
                                           ))
                                   }
                                   .foregroundColor(.orange)
                                   .padding(.horizontal, 20)
                                   .padding(.vertical, 10)
                                   .background(
                                       Capsule()
                                           .fill(.orange.opacity(0.15))
                                   )
                               })
                               .transition(.scale.combined(with: .opacity))
                               .padding(.bottom, 20)
                    }

                    // Main Action Buttons (always visible)
                    HStack(spacing: 24) {
                        // Record Button
                        MainActionButton(
                            icon: recognitionState == .processingSpeech ? "mic.fill" :
                                "mic.circle.fill",
                            label: recognitionState == .processingSpeech ? "Stop" : "Record",
                            color: recognitionState == .processingSpeech ? .red : .blue,
                            isActive: recognitionState == .processingSpeech,
                            isEnabled: recognitionState.canToggleRecognition
                        ) {
                            Task { await toggleRecognition() }
                        }

                        // Draw Button
                        MainActionButton(
                            icon: "paintbrush.pointed.fill",
                            label: "Draw It!",
                            color: .green,
                            isEnabled: enableDrawButton
                        ) {
                            Task { await generateImage(from: currentPrompt) }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }

                // Full-screen dimmer and loading indicator for image generation
                if isGeneratingImage {
                    DimmerBackgroundView()
                    ProgressIndicatorView(descriptionMessage: "Creating your image...")
                }
            }
            .navigationDestination(isPresented: $showEditor) {
                if let generatedImage = generatedImage {
                    ImageEditorView(image: generatedImage)
                        // we don't need these envs here, they are provided in higher level
                        //  .environment(\.drawService, drawService)
                        //  .environment(\.imageSaveService, imageSaveService)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9).combined(with: .opacity),
                            removal: .scale(scale: 1.1).combined(with: .opacity)
                        ))
                }
            }
            .overlay(alignment: .top) {
                if let error = recognitionState.errorMessage {
                    ErrorBannerView(message: error) {
                        self.recognitionState = .waiting
                    }
                    .padding(.top, 60)
                }

                // MARK: we can show alerts about volume from appModel

                // TTS volume warning - using appModel
                // if appModel.showVolumeWarning
                // TTS errors - using appModel
                // or change recognition state when callback from textToSpeechService
            }
            .onChange(of: recognitionState) { _, newValue in
                if case let .speechRecognized(transcription) = newValue {
                    // Auto-play text-to-speech
                    if appModel.autoPlayConfirmation {
                        speakText(transcription)
                    }
                }
            }
        }
    }

    private func toggleRecognition() async {
        guard recognitionState.canToggleRecognition else {
            assertionFailure("toggleRecognition() called when not allowed")
            return
        }
        if recognitionState == .processingSpeech {
            await stopRecognition()
        } else {
            await startRecognition()
        }
    }

    func startRecognition() async {
        recognitionState = .processingSpeech
        do {
            try await speechRecognitionService.startRecognition()
        } catch {
            handleError(error)
        }
    }

    func stopRecognition() async {
        recognitionState = .analysingSpeech
        do {
            //  try await Task.sleep(nanoseconds: 1_000_000_000)
            let transcription = try await speechRecognitionService.stopRecognition()
            recognitionState = .speechRecognized(transcription)
        } catch {
            handleError(error)
        }
    }

    private func speakText(_ text: String) {
        // Stop any ongoing speech
        if textToSpeechService.isSpeaking {
            textToSpeechService.stop()
        }
        textToSpeechService.speak(text)
    }

    private func generateImage(from prompt: String) async {
        isGeneratingImage = true
        guard let text = recognitionState.recognizedText else {
            assertionFailure("generation image from empty prompt is not allowed")
            return
        }
        do {
            let image = try await imageGenerationService.generateImage(from: text)
            generatedImage = image
            showEditor = true
            recognitionState = .waiting
        } catch {
            handleError(error)
        }
        isGeneratingImage = false
    }

    // let's think about it, may be some errors shouldn't look very bad
    private func handleError(_ error: Error) {
        if let speechError = error as? SpeechRecognitionError {
            recognitionState = .error(speechError.errorDescription ?? "Unknown error")
        } else {
            recognitionState = .error(error.localizedDescription)
        }
    }
}

// swiftlint:disable force_try
#Preview {
    SpeechRecognitionView()
        .environment(\.speechRecognitionService, try! MockSpeechRecognitionService(settings:
            SpeechRecognitionSettings(locale: Locale(identifier: "en-US"), requiresOnDevice: true)))
        .environment(\.textToSpeechService, MockTextToSpeechService(settings:
            TextToSpeechSettings(locale: Locale(identifier: "en-US"))))
}

// swiftlint:enable force_try
