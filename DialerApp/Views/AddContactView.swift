import PhotosUI
import SwiftData
import SwiftUI

struct AddContactView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var groups: [ContactGroup]
    private let contact: Contact?
    @State private var firstName: String
    @State private var lastName: String
    @State private var company: String
    @State private var jobTitle: String
    @State private var primaryPhone: String
    @State private var secondaryPhone: String
    @State private var email: String
    @State private var location: String
    @State private var notes: String
    @State private var favorite: Bool
    @State private var photoData: Data?
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedGroupIDs: Set<UUID>

    init(contact: Contact? = nil) {
        self.contact = contact
        let projectID = AppScope.projectID
        _groups = Query(filter: #Predicate<ContactGroup> { $0.projectID == projectID && $0.isActive && $0.deletedAt == nil }, sort: [SortDescriptor(\ContactGroup.name)])
        _firstName = State(initialValue: contact?.firstName ?? ""); _lastName = State(initialValue: contact?.lastName ?? "")
        _company = State(initialValue: contact?.company ?? ""); _jobTitle = State(initialValue: contact?.jobTitle ?? "")
        _primaryPhone = State(initialValue: contact?.primaryPhone ?? ""); _secondaryPhone = State(initialValue: contact?.secondaryPhone ?? "")
        _email = State(initialValue: contact?.email ?? ""); _location = State(initialValue: contact?.location ?? "")
        _notes = State(initialValue: contact?.notes ?? ""); _favorite = State(initialValue: contact?.isFavorite ?? false)
        _photoData = State(initialValue: contact?.photoData); _selectedGroupIDs = State(initialValue: Set(contact?.groups.map(\.id) ?? []))
    }
    private var canSave: Bool { !firstName.trimmingCharacters(in: .whitespaces).isEmpty && PhoneNumber.normalized(primaryPhone) != nil }
    var body: some View {
        NavigationStack {
            Form {
                Section { HStack { Spacer(); PhotosPicker(selection: $photoItem, matching: .images) { VStack { if let photoData { AvatarView(initials: "", seed: 0, photoData: photoData, size: 96) } else { Image(systemName: "person.crop.circle.badge.plus").font(.system(size: 70)) }; Text("Fotoğraf Seç") } }; Spacer() } }
                Section("Kişi") { TextField("Ad", text: $firstName).textContentType(.givenName); TextField("Soyad", text: $lastName).textContentType(.familyName); TextField("Şirket", text: $company).textContentType(.organizationName); TextField("Görev", text: $jobTitle) }
                Section("İletişim") { TextField("Cep telefonu", text: $primaryPhone).keyboardType(.phonePad); TextField("Alternatif telefon", text: $secondaryPhone).keyboardType(.phonePad); TextField("E-posta", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never); TextField("Konum", text: $location) }
                Section("Notlar") { TextField("Notlar", text: $notes, axis: .vertical).lineLimit(3...6); Toggle("Favori", isOn: $favorite) }
                Section("Gruplar") { ForEach(groups) { group in Toggle(group.name, isOn: Binding(get: { selectedGroupIDs.contains(group.id) }, set: { $0 ? selectedGroupIDs.insert(group.id) : selectedGroupIDs.remove(group.id) })) } }
            }.navigationTitle(contact == nil ? "Yeni Kişi" : "Kişiyi Düzenle").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Vazgeç") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("Kaydet", action: save).disabled(!canSave) } }
                .onChange(of: photoItem) { _, item in Task { photoData = try? await item?.loadTransferable(type: Data.self) } }
        }
    }
    private func save() {
        guard let normalized = PhoneNumber.normalized(primaryPhone) else { return }
        let model = contact ?? Contact(firstName: firstName, primaryPhone: normalized)
        model.firstName = firstName.trimmingCharacters(in: .whitespaces); model.lastName = lastName.trimmingCharacters(in: .whitespaces)
        model.company = company; model.jobTitle = jobTitle; model.primaryPhone = normalized
        model.secondaryPhone = secondaryPhone.isEmpty ? nil : secondaryPhone; model.email = email.isEmpty ? nil : email
        model.location = location.isEmpty ? nil : location; model.notes = notes.isEmpty ? nil : notes; model.isFavorite = favorite; model.photoData = photoData
        model.groups = groups.filter { selectedGroupIDs.contains($0.id) }
        if contact == nil { context.insert(model) }; try? context.save(); dismiss()
    }
}
