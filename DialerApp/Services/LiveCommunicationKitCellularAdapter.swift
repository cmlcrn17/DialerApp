import Foundation

#if DIALER_ENABLE_LIVE_COMMUNICATION_KIT && canImport(LiveCommunicationKit)
import LiveCommunicationKit

/// Entitlement-gated iOS 26 adapter. This is intentionally compiled only for a
/// provisioning profile approved for `com.apple.developer.dialing-app`.
@available(iOS 26.0, *)
@MainActor
struct LiveCommunicationKitCellularAdapter: CallingService {
    private static let conversationManager = ConversationManager(configuration: .init())

    func call(phoneNumber rawNumber: String) async throws {
        guard let number = PhoneNumber.normalized(rawNumber) else {
            throw CallError.invalidNumber
        }

        let handle = Handle(type: .phoneNumber, value: number)
        let action = StartConversationAction(conversationUUID: UUID(), handle: handle)
        try await Self.conversationManager.perform([action])
    }
}
#endif
