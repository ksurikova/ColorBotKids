import SwiftUI

struct BaseBannerView: View {
    let message: String
    let icon: Image
    let duration: TimeInterval?
    let onClose: (() -> Void)?

    @State private var isVisible = false
    @State private var autoDismissTask: Task<Void, Never>?

    init(message: String, icon: Image, duration: TimeInterval?, onClose: (() -> Void)?) {
        self.message = message
        self.icon = icon
        self.duration = duration
        self.onClose = onClose
        // print("🚩 [Banner] Init with message: \(message)")
    }

    var body: some View {
        HStack(spacing: 16) {
            icon
                .font(.title3)
                .foregroundColor(.orange)

            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            if onClose != nil {
                Button(action: { dismiss() }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.orange.opacity(0.8))
                        .font(.title3)
                })
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThickMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.orange.opacity(0.5), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
        .padding(.horizontal, 20)
        .offset(y: isVisible ? 0 : -150)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            // print("🚩 [Banner] onAppear triggered")
            present()
        }
        .onDisappear {
            // print("🚩 [Banner] onDisappear triggered")
        }
    }

    private func present() {
        // why Task? - decoupling the animation from the onAppear call stack to avoid SwiftUI layout
        // conflicts.
        Task { @MainActor in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isVisible = true
            }

            guard let duration, duration > 0 else { return }

            autoDismissTask?.cancel()
            autoDismissTask = Task {
                try? await Task.sleep(for: .seconds(duration))
                guard !Task.isCancelled else { return }
                dismiss()
            }
        }
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isVisible = false
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.5))
            onClose?()
        }
    }
}
