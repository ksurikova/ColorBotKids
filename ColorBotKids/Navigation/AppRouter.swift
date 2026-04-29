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

    private let permissionManager: PermissionManager
    private let sessionManager: SessionManager
    private let configurationManager: ConfigurationManager
    private let builder: ViewModelBuilder

    // MARK: - State

    @Published var path = NavigationPath()
    @Published private(set) var rootRoute: Route = .initializing

    private var isInitializing = true
    private var cancellables = Set<AnyCancellable>()

    init(builder: ViewModelBuilder,
         configurationManager: ConfigurationManager,
         permissionManager: PermissionManager,
         sessionManager: SessionManager) {
        self.builder = builder
        self.configurationManager = configurationManager
        self.sessionManager = sessionManager
        self.permissionManager = permissionManager
        setupObservers()
    }

    // MARK: - Initialization & Logic

    func finishInitialization() {
        isInitializing = false

        // 1. Set the background (Root)
        rootRoute = computeRootRoute()

        // 2. If there's an active session, push the editor immediately
        syncStackWithSession()

        // print("Router: Init finished. Root: \(rootRoute), Stack Depth: \(path.count)")
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

    @ViewBuilder
    func buildView(for route: Route) -> some View {
        switch route {
        case .initializing:
            ProgressIndicatorView(
                descriptionMessage: String(localized: "onboarding_message_preparingScreen")
            )
        case .aiConfiguration:
            AIConfigurationView(viewModel: builder.makeAiConfigurationViewModel())
        case .speechConfiguration:
            SpeechConfigurationView(viewModel: builder
                .makeSpeechConfigurationViewModel(mode: .onboarding))
        case .photoPermission: PhotoPermissionsView(viewModel:
                builder.makePhotoLibraryViewModel())
        case .main:
            SpeechRecognitionView(viewModel: builder.makeSpeechViewModel(),
                                  settingsViewFactory: { [weak self] in
                                      if let builder = self?.builder {
                                          // The Router builds the final product
                                          SettingsView(viewModel: builder.makeSettingsViewModel())
                                      } else {
                                          EmptyView()
                                      }
                                  })
        case .imageEditor:
            if let vm = builder.makeEditorViewModel() {
                ImageEditorView(viewModel: vm)
            }
        }
    }
}
