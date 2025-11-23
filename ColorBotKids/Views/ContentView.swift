//
//  ContentView.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appModel: AppModel
    @Environment(\.permissionService) private var permissionService
    @Environment(\.speechServiceType) private var speechServiceType
    @Environment(\.textToSpeechServiceType) private var textToSpeechServiceType
    @Environment(\.scenePhase) private var scenePhase
    @State var speechService: SpeechRecognitionService?
    @State var textToSpeechService: TextToSpeechService?
    @State var imageGenerationService: ImageGenerationService?
    @State var currentRoute: AppRoute = .loading
    @State private var wasInBackground = false

    // Track which services have been created
    @State private var hasCreatedImageService = false
    @State private var hasCreatedSpeechServices = false

    init() {}

    var body: some View {
        ZStack {
            BackgroundView()
            // Main content
            routeView
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
        }
        .animation(.easeInOut, value: currentRoute)
        .task {
            await initializeApp()
        }
        .onChange(of: appModel.requiredRoute) { _, newRoute in
            handleRouteChange(newRoute)
        }
        // right now we don't use it
        .onChange(of: scenePhase) { _, newPhase in
            // Track if we went to background (Settings)
            // But we can return not only from Settings
            if newPhase == .background {
                wasInBackground = true
            }

            // Only restart if we were actually in background (not just inactive from dialogs)
            if newPhase == .active && wasInBackground {
                wasInBackground = false
                Task {
                    await handleReturnFromBackground()
                }
            }
        }
    }

    // MARK: presentation logic

    private func initializeApp() async {
        currentRoute = .loading
        try? await Task.sleep(nanoseconds: 500_000_000)
        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
                appModel.loadConfiguration()
            }
            group.addTask {
                await appModel.refreshAllPermissions(using: permissionService)
            }
            await group.waitForAll()
        }

        // MARK: WHY DO WE NEED THIS? ONCNANGE WILL NOT WORK?

        await MainActor.run {
            handleRouteChange(appModel.requiredRoute)
        }
    }

    private func handleReturnFromBackground() async {
        await appModel.refreshAllPermissions(using: permissionService)
        appModel.loadConfiguration()
        // The route will automatically update via onChange(of: appModel.requiredRoute)
        // which will trigger handleRouteChange and redirect user to the correct screen
    }

    private func handleRouteChange(_ newRoute: AppRoute) {
        // Create services when configurations are available
        createServicesIfNeeded()

        // Update the current route with animation
        withAnimation {
            currentRoute = newRoute
        }
    }

    private func createServicesIfNeeded() {
        if appModel.currentConfiguration.isAIConfigured, !hasCreatedImageService {
            createImageGenerationService()
        }

        if appModel.currentConfiguration.isSpeechConfigured, !hasCreatedSpeechServices {
            createSpeechServices()
        }
    }

    private func createImageGenerationService() {
        guard let config = appModel.currentConfiguration.aiConfig else {
            assertionFailure("AI configuration should exist when creating a service")
            return
        }
        imageGenerationService = ImageGenerationServiceFactory.createService(from: config)
        hasCreatedImageService = true
    }

    private func createSpeechServices() {
        do {
            let speechSettings = try appModel.createSpeechRecognitionSettings()
            print("speech settings are done")
            speechService = try speechServiceType.init(settings: speechSettings)
            print("speech service is done")
            let textToSpeechSettings = try appModel.createTTSSettings()
            print("text to speech settings are done")
            textToSpeechService = textToSpeechServiceType.init(settings: textToSpeechSettings)
            print("text to speech service is done")
            setupTextToSpeechCallbacks()

            hasCreatedSpeechServices = true
        } catch {
            assertionFailure("Failed to create speech services: \(error.localizedDescription)")
        }
    }

    private func setupTextToSpeechCallbacks() {
        textToSpeechService?.onVolumeWarning = { [weak appModel] in
            Task { @MainActor in
                appModel?.showVolumeLowWarning()
            }
        }
        textToSpeechService?.onDidFailToPlay = { [weak appModel] in
            Task { @MainActor in
                appModel?.showTTSError()
            }
        }
        // no need to set .onStartSpeaking
    }

    @ViewBuilder
    private var routeView: some View {
        switch currentRoute {
        case .loading:
            ProgressIndicatorView(descriptionMessage: "Preparing your app...")
        case .aiConfiguration:
            AIConfigurationView()
        case .speechConfiguration:
            SpeechConfigurationView()
        case .photoPermission:
            PhotoPermissionsView(photoLibraryStatus: $appModel.photoLibraryStatus)
        case .speechRecognition:
            if let speechService, let textToSpeechService, let imageGenerationService {
                SpeechRecognitionView()
                    .environment(\.speechRecognitionService, speechService)
                    .environment(\.textToSpeechService, textToSpeechService)
                    .environment(\.imageGenerationService, imageGenerationService)
            } else {
                // Fallback - shouldn't happen but prevents crashes
            }
        }
    }
}

#Preview("AI config") {
    ContentView()
        .environmentObject(AppModel.mockUnconfigured())
        .environment(
            \.permissionService,
            MockPermissionService(
            )
        )
}

#Preview("Speech config") {
    ContentView()
        .environmentObject(AppModel.mockWithAI())
        .environment(
            \.permissionService,
            MockPermissionService(
            )
        )
}

private func makeReadyPreview() -> some View {
    MockSpeechRecognitionService.canCreateWithCurrentSettingsResponse = true
    let speechServiceType: SpeechRecognitionService.Type = MockSpeechRecognitionService.self
    let permissionService = MockPermissionService(permissionStatuses: [
        "microphone": .authorized,
        "speechRecognition": .authorized,
        "photoLibrary": .authorized,
    ])

    return ContentView()
        .environmentObject(AppModel.mockFullyConfigured())
        .environment(
            \.permissionService,
            permissionService
        )
        .environment(\.speechServiceType, speechServiceType)
}

#Preview("Ready") {
    makeReadyPreview()
}
