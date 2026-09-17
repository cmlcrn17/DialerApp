import Foundation

/// Cross-cutting presentation point for the active call screen. Kept free of
/// LiveCommunicationKit types so views can observe it without depending on
/// the entitlement-gated adapter.
@MainActor
final class ActiveCallCenter: ObservableObject {
    static let shared = ActiveCallCenter()

    @Published var current: ActiveCallViewModel?

    private init() {}
}
