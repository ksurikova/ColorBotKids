//
//  AIConfigurationView.swift
//  ColorBotKids
//
//  Created by ksurikova on 7.11.2025.
//
import SwiftUI

struct AIConfigurationView: View {
    @StateObject private var viewModel: AIConfigurationViewModel

    init(viewModel: AIConfigurationViewModel) {
        _viewModel =
            StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ConfigurationContainerView(
            error: viewModel.error.map { $0 as Error },
            onDismissError: {
                viewModel.dismissError()
            },
            content: {
                OnboardingHeaderView(
                    icon: "brain.head.profile",
                    title: "onboarding_title_AI"
                )

                providerPicker

                if viewModel.requiresApiKey {
                    VStack(alignment: .leading, spacing: 8) {
                        apiKeyField

                        // never have nil here, but to satisfy the optionality of the view model
                        // property
                        Text(viewModel.apiKeyFooterText ?? "")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                            .transition(.opacity)
                    }
                    .animation(.easeInOut(duration: 0.2), value: viewModel.selectedProvider)
                }

                Spacer()

                ConfigurationActionButton(
                    isEnabled: viewModel.isValid,
                    isProcessing: viewModel.isSaving,
                    action: { viewModel.save()
                    }
                )
            }
        )
    }

    // MARK: - Subviews

    private var providerPicker: some View {
        HStack {
            Text("onboarding_label_provider").plainStyle()
            Picker("", selection: $viewModel.selectedProvider) {
                ForEach(ImageProvider.allCases, id: \.self) { provider in
                    Text(provider.displayName).tag(provider)
                }
            }
            .defaultStyle()
        }
    }

    private var apiKeyField: some View {
        APIKeyFieldView(placeholder: "onboarding_label_enterApiKey", text: $viewModel.apiKey)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
}

#Preview {
    let vm = PreviewMocks.aiConfigurationViewModel
    return AIConfigurationView(viewModel: vm)
}

#Preview("AI Configuration - Stubbed logic") {
    let container = StubDependencyContainer()
    let builder = DefaultViewModelBuilder(dependencies: container)
    let vm = builder.makeAiConfigurationViewModel()

    return AIConfigurationView(viewModel: vm)
}
