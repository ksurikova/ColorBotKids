//
//  AppRouter.swift
//  ColorBotKids
//
//  Created by ksurikova on 4.02.2026.
//
import Combine
import SwiftUI

@MainActor
final class AppRouter: ObservableObject {
    // MARK: - Route Definition

    enum Route: Equatable, Hashable {
        case initializing
        case aiConfiguration
        case speechConfiguration
        case photoPermission
        case main
        case imageEditor

        var id: String {
            switch self {
            case .initializing: return "initializing"
            case .aiConfiguration: return "aiConfiguration"
            case .speechConfiguration: return "speechConfiguration"
            case .photoPermission: return "photoPermission"
            case .main: return "main"
            case .imageEditor: return "imageEditor"
            }
        }

        var isOnboarding: Bool {
            switch self {
            case .initializing, .aiConfiguration,
                 .speechConfiguration, .photoPermission: true
            case .main, .imageEditor: false
            }
        }
    }

    // MARK: - Dependencies

    private let mainServicesManager: MainServicesManager
    private let permissionManager: PermissionManager
    private let sessionManager: SessionManager
    private let imageToolingManager: ImageToolingManager
    private let settingsService: SettingsService

    // Lazily initialized: Created only when needed (first edit session) and reused thereafter.
    private lazy var editorPersistenceInteractor: EditorPersistenceInteractor =
        .init(sessionManager: sessionManager)

    // MARK: - Cached ViewModels

    // Keeps the speech VM alive to retain critical service state.
    private var cachedSpeechVM: SpeechRecognitionViewModel?

    // MARK: - State

    @Published private(set) var currentRoute: Route = .initializing
    private var isInitializing = true
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Integration

    var configurationManager: ConfigurationManager {
        mainServicesManager.configurationManager
    }

    // MARK: - Initialization

    init(
        mainServicesManager: MainServicesManager,
        permissionManager: PermissionManager,
        sessionManager: SessionManager,
        imageToolingManager: ImageToolingManager,
        settingsService: SettingsService
    ) {
        self.mainServicesManager = mainServicesManager
        self.permissionManager = permissionManager
        self.sessionManager = sessionManager
        self.imageToolingManager = imageToolingManager
        self.settingsService = settingsService

        setupObservers()
    }

    // MARK: - Route Management

    func finishInitialization() {
        isInitializing = false
        updateRouteIfNeeded()
        print("✅ Router: Initialization finished, route: \(currentRoute.id)")
    }

    private func setupObservers() {
        // 1. Observe Configuration
        configurationManager.configurationSaved
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateRouteIfNeeded()
            }
            .store(in: &cancellables)

        // 2. Listen to all permissions
        Publishers.MergeMany(
            permissionManager.microphone.eraseToAnyPublisher(),
            permissionManager.speechRecognition.eraseToAnyPublisher(),
            permissionManager.photoLibrary.eraseToAnyPublisher()
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] _ in
            self?.updateRouteIfNeeded()
        }
        .store(in: &cancellables)

        // 3. Observe Session (Explicit Subject)
        sessionManager.sessionChanged
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateRouteIfNeeded()
            }
            .store(in: &cancellables)
    }

    // MARK: - Routing

    private func updateRouteIfNeeded() {
        guard !isInitializing else { return }

        let newRoute = computeRoute()
        if currentRoute != newRoute {
            print("🔄 Route changed: \(currentRoute.id) → \(newRoute.id)")
            currentRoute = newRoute
        }
    }

    private func computeRoute() -> Route {
        if sessionManager.currentSession != nil {
            return .imageEditor
        }

        if configurationManager.configuration.aiConfig == nil {
            return .aiConfiguration
        }

        if let caps = configurationManager.currentSpeechCapabilities {
            if !caps.isCriticalValid {
                return .speechConfiguration
            }
        } else {
            return .speechConfiguration
        }

        if !permissionManager.hasSpeechPermissions {
            return .speechConfiguration
        }

        if permissionManager.photoLibrary.value == .notDetermined {
            return .photoPermission
        }

        return .main
    }

    // MARK: - View

    @ViewBuilder
    func buildView() -> some View {
        if currentRoute.isOnboarding {
            buildOnboardingView()
        } else {
            buildAppView()
        }
    }

    @ViewBuilder
    private func buildOnboardingView() -> some View {
        switch currentRoute {
        case .initializing:
            ProgressIndicatorView(
                descriptionMessage: String(localized: "onboarding_message_preparingApp")
            )
        case .aiConfiguration:
            AIConfigurationView(configManager: configurationManager)
        case .speechConfiguration:
            let viewModel = SpeechConfigurationViewModel(
                configManager: configurationManager,
                permissionManager: permissionManager
            )
            SpeechConfigurationView(viewModel: viewModel)
        case .photoPermission:
            PhotoPermissionsView(permissionManager: permissionManager)
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func buildAppView() -> some View {
        ZStack {
            SpeechRecognitionView(
                configManager: configurationManager,
                permissionManager: permissionManager,
                viewModel: speechViewModel()
            )
            .opacity(currentRoute == .main ? 1 : 0)
            .allowsHitTesting(currentRoute == .main)

            if let editorVM = editorViewModel() {
                NavigationStack {
                    ImageEditorView(viewModel: editorVM)
                }
                .transition(.opacity)
                .opacity(currentRoute == .imageEditor ? 1 : 0)
                .allowsHitTesting(currentRoute == .imageEditor)
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
        guard let currentSession = sessionManager.currentSession else {
            // No active session.
            return nil
        }
        // create a fresh VM using the long-lived interactor.
        let vm = ImageEditorViewModel(
            persistenceInteractor: editorPersistenceInteractor,
            toolingManager: imageToolingManager,
            permissionManager: permissionManager,
            settingsService: settingsService
        )
        return vm
    }
}
