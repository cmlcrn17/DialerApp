import AVFAudio
import Foundation

#if DIALER_ENABLE_LIVE_COMMUNICATION_KIT && canImport(LiveCommunicationKit)
// LiveCommunicationKit's ConversationManager does not currently expose
// Sendable annotations to Swift 6 even though the framework owns the
// synchronization of its asynchronous operations.
@preconcurrency import LiveCommunicationKit

/// Entitlement-gated iOS 26 adapter. This is intentionally compiled only for a
/// provisioning profile approved for `com.apple.developer.dialing-app`.
@available(iOS 26.0, *)
@MainActor
final class LiveCommunicationKitCellularAdapter: NSObject, CallingService, ConversationManagerDelegate {
    static let shared = LiveCommunicationKitCellularAdapter()

    private let conversationManager: ConversationManager
    private var activeConversationUUID: UUID?

    private override init() {
        conversationManager = ConversationManager(
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
        super.init()
        conversationManager.delegate = self
    }

    func call(phoneNumber rawNumber: String) async throws {
        guard let normalizedNumber = PhoneNumber.normalized(rawNumber) else {
            throw CallError.invalidNumber
        }

        let conversationUUID = UUID()
        let handle = Handle(type: .phoneNumber, value: normalizedNumber)
        let action = StartConversationAction(
            conversationUUID: conversationUUID,
            handles: [handle],
            isVideo: false
        )

        activeConversationUUID = conversationUUID
        let screen = ActiveCallViewModel(phoneNumber: PhoneNumber.formatted(normalizedNumber))
        screen.onToggleMute = { [weak self] in self?.toggleMute() }
        screen.onToggleHold = { [weak self] in self?.toggleHold() }
        screen.onToggleSpeaker = { [weak self] in self?.toggleSpeaker() }
        screen.onEndCall = { [weak self] in self?.endCall() }
        ActiveCallCenter.shared.current = screen

        do {
            try await conversationManager.perform([action])
        } catch {
            ActiveCallCenter.shared.current = nil
            activeConversationUUID = nil
            throw error
        }
    }

    private func toggleMute() {
        guard let uuid = activeConversationUUID, let screen = ActiveCallCenter.shared.current else { return }
        let newValue = !screen.isMuted
        let action = MuteConversationAction(conversationUUID: uuid, isMuted: newValue)
        Task {
            try? await conversationManager.perform([action])
            screen.isMuted = newValue
        }
    }

    private func toggleHold() {
        guard let uuid = activeConversationUUID, let screen = ActiveCallCenter.shared.current else { return }
        let newValue = !screen.isOnHold
        let action = PauseConversationAction(conversationUUID: uuid, isPaused: newValue)
        Task {
            try? await conversationManager.perform([action])
            screen.isOnHold = newValue
        }
    }

    private func toggleSpeaker() {
        guard let screen = ActiveCallCenter.shared.current else { return }
        let newValue = !screen.isSpeakerOn
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(newValue ? .speaker : .none)
            screen.isSpeakerOn = newValue
        } catch {
            // Audio route change failed; leave the toggle state untouched.
        }
    }

    private func endCall() {
        guard let uuid = activeConversationUUID else { return }
        let action = EndConversationAction(conversationUUID: uuid)
        Task { try? await conversationManager.perform([action]) }
    }

    nonisolated func conversationManager(_ manager: ConversationManager, conversationChanged conversation: Conversation) {
        Task { @MainActor in
            switch conversation.state {
            case .left:
                ActiveCallCenter.shared.current = nil
                self.activeConversationUUID = nil
            default:
                break
            }
        }
    }

    nonisolated func conversationManagerDidBegin(_ manager: ConversationManager) {}

    nonisolated func conversationManagerDidReset(_ manager: ConversationManager) {
        Task { @MainActor in
            ActiveCallCenter.shared.current = nil
            self.activeConversationUUID = nil
        }
    }

    nonisolated func conversationManager(_ manager: ConversationManager, perform action: ConversationAction) {
        switch action {
        case let start as StartConversationAction:
            start.fulfill(dateStarted: Date())
        case let end as EndConversationAction:
            end.fulfill(dateEnded: Date())
        default:
            action.fulfill()
        }
    }

    nonisolated func conversationManager(_ manager: ConversationManager, timedOutPerforming action: ConversationAction) {
        action.fail()
    }

    nonisolated func conversationManager(_ manager: ConversationManager, didActivate audioSession: AVAudioSession) {}

    nonisolated func conversationManager(_ manager: ConversationManager, didDeactivate audioSession: AVAudioSession) {}
}
#endif
