import SwiftData
import SwiftUI

@MainActor
final class CallCoordinator: ObservableObject {
    @Published var errorMessage: String?
    private let service: any CallingService

    init(service: any CallingService) { self.service = service }

    func call(_ contact: Contact, context: ModelContext) {
        let callScreen = ActiveCallCenter.shared.present(
            phoneNumber: contact.primaryPhone,
            contactName: contact.displayName
        )
        Task {
            do {
                // Sunumun arama API'si uygulamayı arka plana almadan önce çizilmesine izin ver.
                await Task.yield()
                try await service.call(phoneNumber: contact.primaryPhone)
                context.insert(CallRecord(contactName: contact.displayName, phoneNumber: contact.primaryPhone,
                                          contactID: contact.id, company: contact.company))
                try context.save()
            } catch {
                ActiveCallCenter.shared.dismiss(callScreen)
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var calls: CallCoordinator
    @AppStorage("didSeedDemoDirectory") private var didSeed = false

    init(callingService: any CallingService) {
        _calls = StateObject(wrappedValue: CallCoordinator(service: callingService))
    }

    var body: some View {
        TabView {
            HomeView().tabItem { Label("Ana Sayfa", systemImage: "phone.fill") }
            GroupsView().tabItem { Label("Gruplar", systemImage: "person.2.fill") }
            ContactsView().tabItem { Label("Kişiler", systemImage: "person.fill") }
            RecentsView().tabItem { Label("Son Aramalar", systemImage: "clock.fill") }
        }
        .tint(.blue)
        .environmentObject(calls)
        .alert("Arama başlatılamadı", isPresented: Binding(
            get: { calls.errorMessage != nil }, set: { if !$0 { calls.errorMessage = nil } }
        )) { Button("Tamam", role: .cancel) {} } message: { Text(calls.errorMessage ?? "") }
        .task { seedIfNeeded() }
    }

    private func seedIfNeeded() {
        guard !didSeed else { return }
        let groups = ["Geobilgi", "Müşteriler", "Tedarikçiler", "Arkadaşlar", "Aile", "Akyazı", "Proje Ekipleri"]
            .map { ContactGroup(name: $0) }
        groups.forEach(context.insert)
        let people = [
            ("Ceren", "Taşsın", "", "", "+90 (530) 737 00 83", "", [Int]())
        ]
        for (index, p) in people.enumerated() {
            let contact = Contact(firstName: p.0, lastName: p.1, company: p.2, jobTitle: p.3,
                                  primaryPhone: p.4, email: "\(p.0.lowercased())@example.com",
                                  location: p.5, colorSeed: index, isFavorite: index < 5)
            contact.groups = p.6.map { groups[$0] }
            context.insert(contact)
        }
        try? context.save()
        didSeed = true
    }
}
