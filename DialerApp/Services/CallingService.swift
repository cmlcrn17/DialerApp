import Foundation
import UIKit

enum CallError: LocalizedError {
    case invalidNumber
    case unavailable

    var errorDescription: String? {
        switch self {
        case .invalidNumber: "Geçerli bir telefon numarası girin."
        case .unavailable: "Bu aygıtta hücresel arama başlatılamıyor."
        }
    }
}

@MainActor
protocol CallingService {
    func startCellularCall(to rawNumber: String) async throws
}

/// The dependable path for ordinary SIM calls. iOS asks the user to confirm the call.
@MainActor
struct SystemURLCallingService: CallingService {
    func startCellularCall(to rawNumber: String) async throws {
        guard let number = PhoneNumber.normalized(rawNumber),
              let url = URL(string: "tel:\(number)"),
              UIApplication.shared.canOpenURL(url) else {
            throw CallError.invalidNumber
        }

        let opened = await UIApplication.shared.open(url)
        guard opened else { throw CallError.unavailable }
    }
}

/// Selects the modern implementation when the signed build has Apple's dialing-app
/// entitlement; otherwise it deliberately retains the standard cellular fallback.
@MainActor
struct CellularCallingService: CallingService {
    private let fallback = SystemURLCallingService()

    func startCellularCall(to rawNumber: String) async throws {
        // LiveCommunicationKitCellularAdapter is kept in its own integration file.
        // Enable DIALER_ENABLE_LIVE_COMMUNICATION_KIT only after Apple grants the
        // dialing-app entitlement to the selected App ID.
        #if DIALER_ENABLE_LIVE_COMMUNICATION_KIT
        if #available(iOS 26.0, *) {
            try await LiveCommunicationKitCellularAdapter().startCellularCall(to: rawNumber)
            return
        }
        #endif
        try await fallback.startCellularCall(to: rawNumber)
    }
}
