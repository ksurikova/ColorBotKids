//
//  AppMainServices.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.01.2026.
//

struct AppMainServices: Equatable {
    let speechRecognition: SpeechRecognitionService
    var textToSpeech: TextToSpeechService? // var to allow callback mutation
    let imageGeneration: ImageGenerationService

    static func == (lhs: Self, rhs: Self) -> Bool {
        // Compare by object identity since services are reference types
        ObjectIdentifier(lhs.speechRecognition as AnyObject) ==
            ObjectIdentifier(rhs.speechRecognition as AnyObject) &&
            ObjectIdentifier(lhs.textToSpeech as AnyObject) ==
            ObjectIdentifier(rhs.textToSpeech as AnyObject) &&
            ObjectIdentifier(lhs.imageGeneration as AnyObject) ==
            ObjectIdentifier(rhs.imageGeneration as AnyObject)
    }
}
