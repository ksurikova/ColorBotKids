//
//  AIConfigurationView.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//
import SwiftUI

struct AIConfigurationView: View {
    @EnvironmentObject var appModel: AppModel
    @State var selectedProvider: ImageProvider = .mock
    @State var apiKey: String = ""
    @State var showValidation: Bool = false
    @State private var isSaving = false
    @State private var error: Error?

    var requiresApiKey: Bool {
        selectedProvider != .mock
    }

    var canSave: Bool {
        !requiresApiKey || !apiKey.isEmpty
    }

    init() {
        // needed init
    }

    var body: some View {
        VStack(spacing: 24) {
            // Error banner at the top
            if let error {
                BaseBannerView(
                    message: error.localizedDescription,
                    icon: Image(systemName: "exclamationmark.triangle.fill"),
                    duration: nil,
                    onClose: { self.error = nil }
                )
            }

            DefaultIcon(
                name: "brain.head.profile",
                foregroundStyle: AnyShapeStyle(LinearGradient.bluePurple)
            )

            Text("Setup AI Provider").mainStyle()

            HStack {
                Text("Select provider").plainStyle()
                Picker("", selection: $selectedProvider) {
                    ForEach(ImageProvider.allCases, id: \.self) { provider in
                        Text(provider.displayName).tag(provider)
                    }
                }
                .defaultStyle()
            }
            // API Key Section (only for non-mock providers)
            if requiresApiKey {
                VStack(alignment: .leading, spacing: 8) {
                    SecureField("Enter your API key", text: $apiKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            }

            Button("Save & Continue") {
                saveConfiguration()
            }
            .buttonStyle(.primary)
            .disabled(!canSave || isSaving)
            Spacer()
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .padding()
        .onChange(of: selectedProvider) { _, _ in
            // Clear API key when switching to mock
            if !requiresApiKey {
                apiKey = ""
            }
        }
    }

    private func saveConfiguration() {
        isSaving = true
        let keyToSave = selectedProvider == .mock ? "mock-key" : apiKey
        let config = AIConfiguration(
            provider: selectedProvider,
            apiKey: keyToSave
        )
        do {
            try appModel.updateAIConfiguration(config)
            // may be we do not need it
            isSaving = false
        } catch {
            isSaving = false
            self.error = error
        }
    }
}

private extension AIConfigurationView {
    // Custom initializer for Previews
    init(
        selectedProvider: ImageProvider = .mock,
        apiKey: String = "",
        showValidation: Bool = false,
        error: Error? = nil
    ) {
        _selectedProvider = State(initialValue: selectedProvider)
        _apiKey = State(initialValue: apiKey)
        _showValidation = State(initialValue: showValidation)
        _error = State(initialValue: error)
    }
}

#Preview {
    AIConfigurationView()
        .environmentObject(AppModel.mockUnconfigured())
}

#Preview("Error banner visible") {
    AIConfigurationView(
        error: NSError(
            domain: "",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Previewed error message"]
        )
    )
    .environmentObject(AppModel.mockUnconfigured())
}

#Preview("OpenAI provider, missing API key") {
    AIConfigurationView(
        selectedProvider: .openAI,
        apiKey: "",
        error: nil
    )
    .environmentObject(AppModel.mockUnconfigured())
}

#Preview("Already configured with Stability AI") {
    AIConfigurationView()
        .environmentObject(AppModel.mockWithAI(
            provider: .stabilityAI,
            apiKey: "sk-test-key"
        ))
}
