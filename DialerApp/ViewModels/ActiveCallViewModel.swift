import Foundation

@MainActor
final class ActiveCallViewModel: ObservableObject, Identifiable {
    let id = UUID()
    let phoneNumber: String

    @Published var isMuted = false
    @Published var isOnHold = false
    @Published var isSpeakerOn = false
    @Published var elapsedSeconds = 0

    var onToggleMute: () -> Void = {}
    var onToggleHold: () -> Void = {}
    var onToggleSpeaker: () -> Void = {}
    var onEndCall: () -> Void = {}

    private var timer: Timer?

    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.elapsedSeconds += 1 }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    var formattedDuration: String {
        String(format: "%02d:%02d", elapsedSeconds / 60, elapsedSeconds % 60)
    }
}
