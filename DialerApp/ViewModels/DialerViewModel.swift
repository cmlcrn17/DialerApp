import SwiftData
import SwiftUI

@MainActor
final class DialerViewModel: ObservableObject {
    @Published var number = ""
    @Published var errorMessage: String?
    @Published var isCalling = false

    private let callingService: any CallingService

    init(callingService: any CallingService = DefaultDialerCallingService(fallback: SystemFallbackCallingService())) {
        self.callingService = callingService
    }

    func append(_ character: String) {
        guard number.count < 20 else { return }
        number.append(character)
    }

    func deleteLast() { if !number.isEmpty { number.removeLast() } }

    func call(name: String? = nil, context: ModelContext) async {
        guard !isCalling else { return }
        isCalling = true
        defer { isCalling = false }
        let callScreen = ActiveCallCenter.shared.present(phoneNumber: number, contactName: name)
        do {
            await Task.yield()
            try await callingService.call(phoneNumber: number)
            if let normalized = PhoneNumber.normalized(number) {
                context.insert(CallRecord(contactName: name ?? normalized, phoneNumber: normalized))
                try? context.save()
            }
        } catch {
            ActiveCallCenter.shared.dismiss(callScreen)
            errorMessage = error.localizedDescription
        }
    }
}
