import SwiftData
import SwiftUI

struct ContactsView: View {
    @Environment(\.modelContext) private var context
    @Query private var contacts: [Contact]
    @StateObject private var speech = SpeechRecognizer()
    @State private var searchText = ""
    @State private var showingAddContact = false
    @State private var callError: String?
    private let callingService = CellularCallingService()

    init() {
        let projectID = AppScope.projectID
        _contacts = Query(
            filter: #Predicate<Contact> {
                $0.projectID == projectID && $0.isActive && $0.deletedAt == nil
            },
            sort: [SortDescriptor(\Contact.firstName), SortDescriptor(\Contact.lastName)]
        )
    }

    private var filteredContacts: [Contact] {
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return contacts }
        return contacts.filter {
            $0.displayName.localizedCaseInsensitiveContains(term) ||
            $0.phoneNumber.localizedCaseInsensitiveContains(term)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if contacts.isEmpty {
                    ContentUnavailableView(
                        "İlk kişinizi ekleyin",
                        systemImage: "person.crop.circle.badge.plus",
                        description: Text("Kişiler yalnızca bu uygulamada, aygıtınızda saklanır.")
                    )
                } else {
                    List(filteredContacts) { contact in
                        HStack(spacing: 14) {
                            AvatarView(initials: contact.initials, seed: contact.colorSeed)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(contact.displayName).font(.headline)
                                Text(contact.phoneNumber).font(.subheadline).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                Task { await call(contact) }
                            } label: {
                                Image(systemName: "phone.fill")
                                    .frame(width: 40, height: 40)
                                    .background(.indigo.opacity(0.12), in: Circle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(contact.displayName) kişisini ara")
                        }
                        .padding(.vertical, 5)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Kişiler")
            .searchable(text: $searchText, prompt: "İsim veya numara")
            .onChange(of: speech.transcript) { _, value in searchText = value }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { Task { await speech.toggle() } } label: {
                        Image(systemName: speech.isListening ? "waveform.circle.fill" : "mic.circle")
                    }
                    .tint(speech.isListening ? .red : .indigo)
                    .accessibilityLabel(speech.isListening ? "Dinlemeyi durdur" : "Sesle ara")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddContact = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Kişi ekle")
                }
            }
            .sheet(isPresented: $showingAddContact) { AddContactView() }
            .alert("Arama başlatılamadı", isPresented: Binding(
                get: { callError != nil }, set: { if !$0 { callError = nil } }
            )) { Button("Tamam") { callError = nil } } message: { Text(callError ?? "") }
        }
    }

    private func call(_ contact: Contact) async {
        do {
            try await callingService.startCellularCall(to: contact.phoneNumber)
            context.insert(CallRecord(contactName: contact.displayName, phoneNumber: contact.phoneNumber))
            try? context.save()
        } catch { callError = error.localizedDescription }
    }
}
