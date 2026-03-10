import Combine
import SwiftUI

// MARK: - AppRouter

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
    }

    // MARK: - Dependencies

    private let mainServicesManager: MainServicesManager
    private let permissionManager: PermissionManager
    private let sessionManager: SessionManager
    private let imageToolingManager: ImageToolingManager
    private let settingsService: SettingsService

    // MARK: - State

    @Published private(set) var currentRoute: Route = .initializing

    // MARK: - Private State

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
        .store(in: &cancellables) // this was correct in original

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
        // If we have an active editing session, go to editor
        if sessionManager.currentSession != nil {
            return .imageEditor
        }

        // Configuration flow (must complete before permissions)
        if configurationManager.configuration.aiConfig == nil {
            return .aiConfiguration
        }
        // Show speech config screen if ANY of these is true:
        // No speech config.
        // isCriticalValid == false for speech configuration
        // Speech permission missing.
        if let caps = configurationManager.currentSpeechCapabilities {
            if !caps.isCriticalValid {
                return .speechConfiguration
            }
        } else {
            return .speechConfiguration
        }

        if !permissionManager.hasSpeechPermissions {
            return .speechConfiguration // Speech config view handles permissions
        }

        // Optional permissions (photo library)
        if permissionManager.photoLibrary.value == .notDetermined {
            return .photoPermission
        }

        // Everything ready - show main screen
        return .main
    }

    // MARK: - View

    @ViewBuilder
    func buildView() -> some View {
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

        case .main:
            // The Router creates the VM and injects it into the View
            let viewModel = SpeechRecognitionViewModel(
                servicesManager: mainServicesManager,
                sessionManager: sessionManager
            )
            SpeechRecognitionView(
                configManager: configurationManager,
                permissionManager: permissionManager,
                viewModel: viewModel
            )

        case .imageEditor:
            NavigationStack {
                let persistenceInteractor =
                    EditorPersistenceInteractor(sessionManager: sessionManager)

                // The Router creates the VM and injects it into the View
                let viewModel = ImageEditorViewModel(
                    persistenceInteractor: persistenceInteractor,
                    toolingManager: imageToolingManager,
                    permissionManager: permissionManager,
                    settingsService: settingsService
                )
                ImageEditorView(viewModel: viewModel)
            }
        }
    }
}
