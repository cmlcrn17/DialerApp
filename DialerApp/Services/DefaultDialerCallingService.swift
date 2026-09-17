import Foundation

// DEFAULT DIALER IMPLEMENTATION
// LiveCommunicationKit is isolated in LiveCommunicationKitCellularAdapter. The
// compiler flag must only be enabled with Apple's managed dialing entitlement.
@MainActor
struct DefaultDialerCallingService: CallingService {
    let fallback: any CallingService

    func call(phoneNumber: String) async throws {
        #if DIALER_ENABLE_LIVE_COMMUNICATION_KIT && canImport(LiveCommunicationKit)
        if #available(iOS 26.0, *) {
            try await LiveCommunicationKitCellularAdapter.shared.call(phoneNumber: phoneNumber)
            return
        }
        #endif
        try await fallback.call(phoneNumber: phoneNumber)
    }
}
