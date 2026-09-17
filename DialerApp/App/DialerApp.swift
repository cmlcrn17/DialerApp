import SwiftData
import SwiftUI

@main
struct DialerApp: App {
    private let container: ModelContainer = {
        let schema = Schema([Contact.self, ContactGroup.self, CallRecord.self])
        let configuration = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("SwiftData mağazası oluşturulamadı: \(error.localizedDescription)")
        }
    }()

    init() {
        #if DIALER_ENABLE_LIVE_COMMUNICATION_KIT && canImport(LiveCommunicationKit)
        if #available(iOS 26.0, *) {
            _ = LiveCommunicationKitCellularAdapter.shared
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView(callingService: DefaultDialerCallingService(
                fallback: SystemFallbackCallingService()
            ))
        }
        .modelContainer(container)
    }
}
