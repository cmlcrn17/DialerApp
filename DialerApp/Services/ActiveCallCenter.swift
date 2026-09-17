import Foundation

/// Cross-cutting presentation point for the active call screen. Kept free of
/// LiveCommunicationKit types so views can observe it without depending on
/// the entitlement-gated adapter.
@MainActor
final class ActiveCallCenter: ObservableObject {
    static let shared = ActiveCallCenter()

    @Published var current: ActiveCallViewModel?

    private init() {}

    @discardableResult
    func present(phoneNumber: String, contactName: String? = nil) -> ActiveCallViewModel {
        let model = ActiveCallViewModel(
            phoneNumber: PhoneNumber.formatted(phoneNumber),
            contactName: contactName
        )
        model.onEndCall = { [weak self, weak model] in
            guard let self, self.current?.id == model?.id else { return }
            self.current = nil
        }
        current = model
        return model
    }

    func dismiss(_ model: ActiveCallViewModel) {
        guard current?.id == model.id else { return }
        current = nil
    }
}
