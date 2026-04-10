//
//  AVTextToSpeechService.swift
//  ColorBotKids
//
//  Created by ksurikova on 31.10.2025.
//
import AVFoundation

final class AVTextToSpeechService: NSObject, TextToSpeechService, AVSpeechSynthesizerDelegate {
    private let synthesizer: AVSpeechSynthesizer = .init()
    private(set) var settings: TextToSpeechSettings
    private let voice: AVSpeechSynthesisVoice?
    let voiceRate: Float = 0.5
    let voicePitch: Float = 1.1
    private(set) var isAvailable: Bool

    // Volume thresholds
    private let mutedThreshold: Float = 0.0
    private let veryLowThreshold: Float = 0.1
    private let lowThreshold: Float = 0.3

    var onStartSpeaking: (() -> Void)?
    var onDidFailToPlay: (() -> Void)?
    var onVolumeWarning: ((VolumeWarningLevel) -> Void)?

    var isSpeaking: Bool {
        synthesizer.isSpeaking
    }

    required init(settings: TextToSpeechSettings) {
        self.settings = settings
        let voice = AVSpeechSynthesisVoice(language: settings.locale.identifier)
        self.voice = voice
        isAvailable = (voice != nil)

        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        guard isAvailable, let voice else { return }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        // Activate session FIRST so outputVolume is accurate
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.duckOthers]
            )
            try audioSession.setActive(true)
        } catch {
            onDidFailToPlay?()
            return
        }

        // OutputVolume reflects reality only after session is active, so check volume here
        if let warningLevel = checkVolumeLevel() {
            // print("sound is low")
            onVolumeWarning?(warningLevel)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = voiceRate
        utterance.pitchMultiplier = voicePitch
        utterance.voice = voice
        utterance.preUtteranceDelay = 0.1
        synthesizer.speak(utterance)
    }

    func stop() {
        guard isAvailable else { return }
        synthesizer.stopSpeaking(at: .immediate)
    }

    static func isAvailableWithCurrentSettings(_ settings: TextToSpeechSettings) -> Bool {
        AVSpeechSynthesisVoice(language: settings.locale.identifier) != nil
    }

    private func checkVolumeLevel() -> VolumeWarningLevel? {
        let audioSession = AVAudioSession.sharedInstance()
        let volume = audioSession.outputVolume

        if volume == mutedThreshold {
            return .muted
        } else if volume < veryLowThreshold {
            return .veryLow
        } else if volume < lowThreshold {
            return .low
        }
        return nil
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didStart utterance: AVSpeechUtterance
    ) {
        onStartSpeaking?()
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        onDidFailToPlay?()
    }
}
