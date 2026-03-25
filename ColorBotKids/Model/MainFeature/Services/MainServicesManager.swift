//
//  MainServicesManager.swift
//  ColorBotKids
//
//  Created by ksurikova on 4.02.2026.
//
import Combine
import SwiftUI

final class MainServicesManager {
    // MARK: - Dependencies

    let configurationManager: ConfigurationManager
    private let servicesFactory: MainServiceFactory

    private var cancellables = Set<AnyCancellable>()

    init(
        configurationManager: ConfigurationManager,
        servicesFactory: MainServiceFactory
    ) {
        self.configurationManager = configurationManager
        self.servicesFactory = servicesFactory

        configurationManager.configurationSaved
            .sink { [weak self] in
                // Invalidate services so next time they are requested, they are recreated with new
                // config
                self?.services = nil
            }
            .store(in: &cancellables)
    }

    // MARK: - Services (Created on-demand)

    private(set) var services: AppMainServices?

    // MARK: - Service Creation

    // The helper to actually trigger creation from the UI
    func prepareServices() throws {
        try createServicesIfNeeded()
    }

    func configureTTSCallbacks(
        onVolumeWarning: @escaping (VolumeWarningLevel) -> Void,
        onDidFailToPlay: @escaping () -> Void
    ) {
        guard var tts = services?.textToSpeech else { return }
        tts.onVolumeWarning = onVolumeWarning
        tts.onDidFailToPlay = onDidFailToPlay
        services?.textToSpeech = tts
    }

    // Creates services if they don't exist yet. Safe to call multiple times.
    func createServicesIfNeeded() throws {
        // Already created - early return
        guard services == nil else {
            return
        }

        guard configurationManager.isFullyConfigured else {
            throw AppError.serviceCreationFailed("App not fully configured")
        }

        // Attempt to create services
        do {
            services = try servicesFactory.createServices(
                configuration: configurationManager.configuration,
                resolver: configurationManager.resolver
            )

            print("✅ Services created successfully")
        } catch let error as ConfigurationError {
            // Map ConfigurationError to AppError
            throw AppError.map(error)
        } catch {
            // Generic service creation error
            throw AppError.serviceCreationFailed(error.localizedDescription)
        }
    }
}
