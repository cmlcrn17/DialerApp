import Foundation

#if DIALER_ENABLE_LIVE_COMMUNICATION_KIT && canImport(LiveCommunicationKit)
import LiveCommunicationKit

/// Entitlement-gated iOS 26 adapter. This is intentionally compiled only for a
/// provisioning profile approved for `com.apple.developer.dialing-app`.
@available(iOS 26.0, *)
@MainActor
struct LiveCommunicationKitCellularAdapter: CallingService {
    private static let conversationManager = ConversationManager(
        configuration: .init(
            ringtoneName: nil,
            iconTemplateImageData: nil,
            maximumConversationGroups: 1,
            maximumConversationsPerConversationGroup: 1,
            includesConversationInRecents: true,
            supportsVideo: false,
            supportedHandleTypes: [.phoneNumber]
        )
    )

    func call(phoneNumber rawNumber: String) async throws {
        guard PhoneNumber.normalized(rawNumber) != nil else {
            throw CallError.invalidNumber
        }

        let action = StartConversationAction(conversationUUID: UUID())
        try await Self.conversationManager.perform([action])
    }
}
#endif
