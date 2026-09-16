import UIKit

// FALLBACK IMPLEMENTATION
// Uses the documented tel: URL. It initiates an ordinary cellular call and never
// substitutes a VoIP call. iOS remains responsible for confirmation and call UI.
@MainActor
struct SystemFallbackCallingService: CallingService {
    func call(phoneNumber rawNumber: String) async throws {
        guard let number = PhoneNumber.normalized(rawNumber),
              let url = URL(string: "tel:\(number)"),
              UIApplication.shared.canOpenURL(url) else {
            throw CallError.invalidNumber
        }
        guard await UIApplication.shared.open(url) else { throw CallError.unavailable }
    }
}
