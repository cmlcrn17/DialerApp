import SwiftData
import SwiftUI
import UIKit

struct HomeView: View {
    @Query private var contacts: [Contact]
    @Query private var recents: [CallRecord]
    @StateObject private var speech = SpeechRecognizer()
    @State private var searchText = ""

    init() {
        let projectID = AppScope.projectID
        _contacts = Query(filter: #Predicate<Contact> { $0.projectID == projectID && $0.isActive && $0.deletedAt == nil },
                          sort: [SortDescriptor(\Contact.firstName)])
        _recents = Query(filter: #Predicate<CallRecord> { $0.projectID == projectID && $0.isActive && $0.deletedAt == nil },
                         sort: [SortDescriptor(\CallRecord.startedAt, order: .reverse)])
    }
    private var matches: [Contact] {
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return term.isEmpty ? [] : contacts.filter { $0.searchableText.localizedCaseInsensitiveContains(term) }
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    SearchBar(text: $searchText, speech: speech)
                    if !searchText.isEmpty {
                        SectionHeader("Sonuçlar", count: matches.count)
                        ForEach(matches) { ContactCard(contact: $0) }
                    } else {
                        SectionHeader("Favoriler")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(contacts.filter(\.isFavorite)) { contact in
                                    NavigationLink { ContactDetailView(contact: contact) } label: {
                                        VStack { AvatarView(contact: contact, size: 68); Text(contact.firstName).font(.caption).foregroundStyle(.primary) }
                                    }.buttonStyle(.plain)
                                }
                            }
                        }
                        SectionHeader("Yakın Zamanda Arananlar")
                        ForEach(recents.prefix(5)) { RecentRow(record: $0) }
                    }
                }.padding()
            }
            .navigationTitle("Telefon")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { NavigationLink { SettingsView() } label: { Image(systemName: "gearshape.fill") } } }
            .onChange(of: speech.transcript) { _, text in searchText = text }
            .alert("Sesli arama kullanılamıyor", isPresented: Binding(
                get: { speech.errorMessage != nil }, set: { if !$0 { speech.errorMessage = nil } }
            )) {
                Button("Ayarları Aç") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                }
                Button("Vazgeç", role: .cancel) {}
            } message: { Text(speech.errorMessage ?? "") }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    @ObservedObject var speech: SpeechRecognizer
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Kişi, şirket veya numara ara", text: $text)
                .textInputAutocapitalization(.never).accessibilityLabel("Kişi, şirket veya numara ara")
            Button { Task { await speech.toggle() } } label: {
                Image(systemName: speech.isListening ? "stop.fill" : "mic.fill")
                    .foregroundStyle(speech.isListening ? .red : .blue).frame(width: 44, height: 44)
                    .symbolEffect(.pulse, isActive: speech.isListening)
            }.accessibilityLabel(speech.isListening ? "Dinlemeyi durdur" : "Sesli arama")
        }.padding(.leading, 16).padding(.trailing, 4).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct SectionHeader: View {
    let title: String; let count: Int?
    init(_ title: String, count: Int? = nil) { self.title = title; self.count = count }
    var body: some View { HStack { Text(title).font(.title2.bold()); Spacer(); if let count { Text("\(count)").foregroundStyle(.secondary) } } }
}

struct ContactCard: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var calls: CallCoordinator
    let contact: Contact
    var body: some View {
        NavigationLink { ContactDetailView(contact: contact) } label: {
            HStack(spacing: 14) {
                AvatarView(contact: contact, size: 58)
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.displayName).font(.headline)
                    Text([contact.jobTitle, contact.company].filter { !$0.isEmpty }.joined(separator: " · ")).font(.subheadline).foregroundStyle(.secondary)
                    Text([contact.location, PhoneNumber.formatted(contact.primaryPhone)].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · ")).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button { calls.call(contact, context: context) } label: { Image(systemName: "phone.fill").frame(width: 48, height: 48).background(.blue.opacity(0.13), in: Circle()) }
                    .buttonStyle(.plain).accessibilityLabel("\(contact.displayName) kişisini ara")
            }.padding(14).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22))
        }.buttonStyle(.plain)
    }
}

struct RecentRow: View {
    let record: CallRecord
    var body: some View { HStack { Image(systemName: "phone.arrow.up.right.fill").foregroundStyle(.green).frame(width: 44, height: 44).background(.green.opacity(0.1), in: Circle()); VStack(alignment: .leading) { Text(record.contactName).font(.headline); Text(record.company).font(.caption).foregroundStyle(.secondary) }; Spacer(); Text(record.startedAt, format: .relative(presentation: .named)).font(.caption).foregroundStyle(.secondary) } }
}
