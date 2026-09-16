import SwiftData
import SwiftUI

@main
struct DialerApp: App {
    private let container: ModelContainer = {
        let schema = Schema([Contact.self, CallRecord.self])
        let configuration = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("SwiftData mağazası oluşturulamadı: \(error.localizedDescription)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
