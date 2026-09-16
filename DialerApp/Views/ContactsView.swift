import SwiftData
import SwiftUI

struct ContactsView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var calls: CallCoordinator
    @Query private var contacts: [Contact]
    @State private var searchText = ""
    @State private var showingAdd = false
    init() {
        let projectID = AppScope.projectID
        _contacts = Query(filter: #Predicate<Contact> { $0.projectID == projectID && $0.isActive && $0.deletedAt == nil }, sort: [SortDescriptor(\Contact.firstName), SortDescriptor(\Contact.lastName)])
    }
    private var filtered: [Contact] { searchText.isEmpty ? contacts : contacts.filter { $0.searchableText.localizedCaseInsensitiveContains(searchText) } }
    var body: some View {
        NavigationStack {
            List(filtered) { contact in
                NavigationLink { ContactDetailView(contact: contact) } label: {
                    HStack(spacing: 14) { AvatarView(contact: contact); VStack(alignment: .leading) { Text(contact.displayName).font(.headline); Text([contact.company, contact.jobTitle].filter { !$0.isEmpty }.joined(separator: " · ")).font(.caption).foregroundStyle(.secondary) } }
                }
                .swipeActions(edge: .leading) { Button { calls.call(contact, context: context) } label: { Label("Ara", systemImage: "phone.fill") }.tint(.green) }
                .swipeActions { Button { contact.isFavorite.toggle(); try? context.save() } label: { Label("Favori", systemImage: "star.fill") }.tint(.orange) }
            }.listStyle(.plain).navigationTitle("Kişiler").searchable(text: $searchText, prompt: "Kişilerde ara")
                .toolbar { Button { showingAdd = true } label: { Image(systemName: "plus") }.accessibilityLabel("Kişi ekle") }
                .sheet(isPresented: $showingAdd) { AddContactView() }
        }
    }
}
