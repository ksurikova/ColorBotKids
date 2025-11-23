//
//  ColorBotKidsApp.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//

import SwiftUI

@main
struct ColorBotKidsApp: App {
    @StateObject var appModel: AppModel
    private let permissionService = DefaultPermissionService()
    private let speechServiceType: SpeechRecognitionService.Type
    // = LiveSpeechRecognitionService.self
    private let textToSpeechServiceType: TextToSpeechService.Type = AVTextToSpeechService.self
    // MockTextToSpeechService.self
    private let imageSaveService: ImageSaveService = DefaultImageSaveService()
    private let drawService: DrawService = DefaultDrawService()

    init() {
        let speech = LiveSpeechRecognitionService.self
        speechServiceType = speech
        let model = AppModel(
            storage: CommonConfigurationStorage(),
            speechServiceType: speech
        )
        _appModel = StateObject(wrappedValue: model)
    }

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appModel)
                .environment(\.permissionService, permissionService)
                .environment(\.speechServiceType, speechServiceType)
                .environment(\.textToSpeechServiceType, textToSpeechServiceType)
                .environment(\.imageSaveService, imageSaveService)
                .environment(\.drawService, drawService)
        }
    }
}
