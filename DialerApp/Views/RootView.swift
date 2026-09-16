import SwiftData
import SwiftUI

@MainActor
final class CallCoordinator: ObservableObject {
    @Published var errorMessage: String?
    private let service: any CallingService

    init(service: any CallingService) { self.service = service }

    func call(_ contact: Contact, context: ModelContext) {
        Task {
            do {
                try await service.call(phoneNumber: contact.primaryPhone)
                context.insert(CallRecord(contactName: contact.displayName, phoneNumber: contact.primaryPhone,
                                          contactID: contact.id, company: contact.company))
                try context.save()
            } catch {
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
            ("Ahmet", "Çetinkaya", "Geobilgi", "Yazılım Takım Lideri", "+90 532 123 45 67", "Gebze, Kocaeli", [0, 6]),
            ("Ayşe", "Coşkun", "Gemsan", "Satın Alma Müdürü", "0533 210 22 30", "Sakarya", [1, 5]),
            ("Salih", "Yılmaz", "Sanko", "Bölge Müdürü", "5321234567", "Gaziantep", [1]),
            ("Bilal", "Kaya", "Yücel Group", "Finans Uzmanı", "0544 231 42 53", "İstanbul", [2]),
            ("Fatih", "Demir", "Guztech", "Ürün Tasarımcısı", "0555 245 67 89", "Ankara", [6]),
            ("Şafak", "Aydın", "Geobilgi", "CBS Uzmanı", "0530 321 44 55", "Sakarya", [0, 5]),
            ("Ceren", "Aksoy", "Gemsan", "İnsan Kaynakları", "0532 765 43 21", "İzmit", [3]),
            ("Mehmet", "Öztürk", "Sanko", "Operasyon Direktörü", "0536 101 20 30", "Adana", [1]),
            ("Elif", "Şahin", "Geobilgi", "Proje Yöneticisi", "0537 404 50 60", "Gebze, Kocaeli", [0, 6]),
            ("Emre", "Arslan", "Guztech", "iOS Geliştirici", "0538 707 80 90", "İstanbul", [3]),
            ("Zeynep", "Korkmaz", "Yücel Group", "Hukuk Müşaviri", "0539 112 23 34", "Bursa", [4]),
            ("Murat", "Çelik", "Geobilgi", "Saha Mühendisi", "0505 556 67 78", "Akyazı, Sakarya", [0, 5])
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
