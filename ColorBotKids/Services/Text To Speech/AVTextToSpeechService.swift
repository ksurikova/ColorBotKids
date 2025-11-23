//
//  AVTextToSpeechService.swift
//  ColorBotKids
//
//  Created by ksurikova on 31.10.2025.
//

import AVFoundation
import SwiftUI

final class AVTextToSpeechService: NSObject, TextToSpeechService, AVSpeechSynthesizerDelegate {
    private let synthesizer: AVSpeechSynthesizer = .init()
    private(set) var settings: TextToSpeechSettings
    private let voice: AVSpeechSynthesisVoice?
    let voiceRate: Float = 0.5
    let voicePitch: Float = 1.1
    private(set) var isAvailable: Bool

    var onStartSpeaking: (() -> Void)?
    var onDidFailToPlay: (() -> Void)?
    var onVolumeWarning: (() -> Void)?

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
        guard isAvailable, let voice else {
            // Disabled TTS – nothing to speak
            return
        }
        // Stop any ongoing speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        // Check volume before speaking
        if !checkSystemVolume() {
            onVolumeWarning?()
            // Still proceed - user might have headphones
        }
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playback,
                mode: .spokenAudio, // Better for speech than .default
                options: [.duckOthers] // Lower other audio when speaking
            )
            try audioSession.setActive(true)
        } catch {
            onDidFailToPlay?()
            return
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = voiceRate
        utterance.pitchMultiplier = voicePitch
        utterance.voice = voice
        // Slightly longer pre-utterance delay for better cadence
        utterance.preUtteranceDelay = 0.1
        synthesizer.speak(utterance)
    }

    func stop() {
        guard isAvailable else { return }
        synthesizer.stopSpeaking(at: .immediate)
    }

    func pause() {
        guard isAvailable else { return }
        synthesizer.pauseSpeaking(at: .word)
    }

    func resume() {
        guard isAvailable else { return }
        synthesizer.continueSpeaking()
    }

    static func isAvailableWithCurrentSettings(_ settings: TextToSpeechSettings) -> Bool {
        AVSpeechSynthesisVoice(language: settings.locale.identifier) != nil
    }

    private func checkSystemVolume() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        let volume = audioSession.outputVolume
        return volume > 0.0
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        willSpeakRangeOfSpeechString characterRange: NSRange,
        utterance: AVSpeechUtterance
    ) {
        // print("WILL SPEAK - this means audio is working!")
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didStart utterance: AVSpeechUtterance
    ) {
        onStartSpeaking?()
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        // print("DID FINISH speaking")
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        onDidFailToPlay?()
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didPause utterance: AVSpeechUtterance
    ) {
        // print("PAUSED")
    }
}
