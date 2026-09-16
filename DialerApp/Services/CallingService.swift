import Foundation

enum CallError: LocalizedError {
    case invalidNumber
    case unavailable
    case defaultDialerUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidNumber: "Geçerli bir telefon numarası girin."
        case .unavailable: "Arama başlatılamadı."
        case .defaultDialerUnavailable: "Varsayılan Arama yeteneği bu aygıtta kullanılamıyor."
        }
    }
}

@MainActor
protocol CallingService {
    func call(phoneNumber: String) async throws
}
