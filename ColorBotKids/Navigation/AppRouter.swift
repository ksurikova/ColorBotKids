//
//  AppRouter.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.03.2025.
//
import Combine
import SwiftUI

@MainActor
final class AppRouter: ObservableObject {
    // MARK: - Route Definition

    enum Route: Hashable {
        case initializing
        case aiConfiguration
        case speechConfiguration
        case photoPermission
        case main
        case imageEditor
    }

    // MARK: - Dependencies

    private let mainServicesManager: MainServicesManager
    private let permissionManager: PermissionManager
    private let sessionManager: SessionManager
    private let imageToolingManager: ImageToolingManager
    private let settingsService: SettingsService
    private let speechConfigurationDraftService: SpeechConfigurationDraftService
    private let aiConfigurationDraftService: AIConfigurationDraftService

    private lazy var editorPersistenceInteractor: EditorPersistenceInteractor =
        .init(sessionManager: sessionManager)

    // MARK: - State

    @Published var path = NavigationPath()
    @Published private(set) var rootRoute: Route = .initializing

    private var isInitializing = true
    private var cancellables: Set<AnyCancellable> = []
    private var cachedSpeechVM: SpeechRecognitionViewModel?

    var configurationManager: ConfigurationManager {
        mainServicesManager.configurationManager
    }

    init(
        mainServicesManager: MainServicesManager,
        permissionManager: PermissionManager,
        sessionManager: SessionManager,
        imageToolingManager: ImageToolingManager,
        settingsService: SettingsService,
        speechConfigurationDraftService: SpeechConfigurationDraftService,
        aiConfigurationDraftService: AIConfigurationDraftService
    ) {
        self.mainServicesManager = mainServicesManager
        self.permissionManager = permissionManager
        self.sessionManager = sessionManager
        self.imageToolingManager = imageToolingManager
        self.settingsService = settingsService
        self.speechConfigurationDraftService = speechConfigurationDraftService
        self.aiConfigurationDraftService = aiConfigurationDraftService

        setupObservers()
    }

    // MARK: - Initialization & Logic

    func finishInitialization() {
        isInitializing = false

        // 1. Set the background (Root)
        rootRoute = computeRootRoute()

        // 2. If there's an active session, push the editor immediately
        syncStackWithSession()

        print("Router: Init finished. Root: \(rootRoute), Stack Depth: \(path.count)")
    }

    private func setupObservers() {
        // 1. Observe Configuration changes
        configurationManager.configurationSaved
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateRootIfNeeded() }
            .store(in: &cancellables)

        // 2. Observe ALL three permission subjects
        // CombineLatest3 waits for all 3 to have a value (which they always do)
        // and fires whenever any of them changes.
        Publishers.CombineLatest3(
            permissionManager.microphone,
            permissionManager.speechRecognition,
            permissionManager.photoLibrary
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] _, _, _ in
            // We don't need the values here because computeRootRoute()
            // will read them directly from the manager.
            self?.updateRootIfNeeded()
        }
        .store(in: &cancellables)
        // Logic for changing the STACK (Opening/Closing the Editor)
        sessionManager.sessionChanged
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.syncStackWithSession() }
            .store(in: &cancellables)
    }

    private func updateRootIfNeeded() {
        guard !isInitializing else { return }
        let newRoot = computeRootRoute()
        if rootRoute != newRoot {
            rootRoute = newRoot
        }
    }

    private func syncStackWithSession() {
        guard !isInitializing else { return }

        if sessionManager.currentSession != nil {
            // Push editor if not already there (we assume path.count > 0 means editor is shown)
            if path.isEmpty {
                path.append(Route.imageEditor)
            }
        } else {
            // Pop to root if session is cleared
            if !path.isEmpty {
                path = NavigationPath()
            }
        }
    }

    private func computeRootRoute() -> Route {
        if configurationManager.configuration.aiConfig == nil { return .aiConfiguration }

        if let caps = configurationManager.currentSpeechCapabilities {
            if !caps.isCriticalValid { return .speechConfiguration }
        } else { return .speechConfiguration }

        if !permissionManager.hasSpeechPermissions { return .speechConfiguration }

        if permissionManager.photoLibrary.value == .notDetermined { return .photoPermission }

        return .main
    }

    // MARK: - View Building

    @ViewBuilder
    func buildView(path: Binding<NavigationPath>) -> some View {
        switch rootRoute {
        case .initializing:
            ProgressIndicatorView(
                descriptionMessage: String(localized: "onboarding_message_preparingApp")
            )
        case .aiConfiguration:
            AIConfigurationView(
                configManager: configurationManager,
                draftService: aiConfigurationDraftService
            )
        case .speechConfiguration:
            SpeechConfigurationView(
                configManager: configurationManager,
                permissionManager: permissionManager,
                draftService: speechConfigurationDraftService
            )
        case .photoPermission:
            PhotoPermissionsView(permissionManager: permissionManager)
        case .main, .imageEditor:
            buildMainStack(path: path)
        }
    }

    @ViewBuilder
    private func buildMainStack(path: Binding<NavigationPath>) -> some View {
        NavigationStack(path: path) {
            SpeechRecognitionView(
                configManager: configurationManager,
                permissionManager: permissionManager,
                draftService: speechConfigurationDraftService,
                aiDraftService: aiConfigurationDraftService,
                viewModel: speechViewModel()
            )
            .navigationDestination(for: Route.self) { route in
                if route == .imageEditor, let vm = self.editorViewModel() {
                    ImageEditorView(viewModel: vm)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }

    // MARK: - ViewModel Factories

    private func speechViewModel() -> SpeechRecognitionViewModel {
        if let cached = cachedSpeechVM { return cached }
        let vm = SpeechRecognitionViewModel(
            servicesManager: mainServicesManager,
            sessionManager: sessionManager
        )
        cachedSpeechVM = vm
        return vm
    }

    private func editorViewModel() -> ImageEditorViewModel? {
        guard sessionManager.currentSession != nil else { return nil }
        return ImageEditorViewModel(
            persistenceInteractor: editorPersistenceInteractor,
            toolingManager: imageToolingManager,
            permissionManager: permissionManager,
            settingsService: settingsService
        )
    }
}
