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
    private var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
            && PhoneNumber.normalized(primaryPhone) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                photoSection
                identitySection
                contactSection
                notesSection
                groupsSection
            }
            .navigationTitle(contact == nil ? "Yeni Kişi" : "Kişiyi Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { contactToolbar }
            .onChange(of: photoItem, loadSelectedPhoto)
        }
    }

    private var photoSection: some View {
        Section {
            HStack {
                Spacer()
                PhotosPicker(selection: $photoItem, matching: .images) {
                    VStack {
                        if let photoData {
                            AvatarView(initials: "", seed: 0, photoData: photoData, size: 96)
                        } else {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 70))
                        }
                        Text("Fotoğraf Seç")
                    }
                }
                Spacer()
            }
        }
    }

    private var identitySection: some View {
        Section("Kişi") {
            TextField("Ad", text: $firstName).textContentType(.givenName)
            TextField("Soyad", text: $lastName).textContentType(.familyName)
            TextField("Şirket", text: $company).textContentType(.organizationName)
            TextField("Görev", text: $jobTitle)
        }
    }

    private var contactSection: some View {
        Section("İletişim") {
            TextField("Cep telefonu", text: $primaryPhone).keyboardType(.phonePad)
            TextField("Alternatif telefon", text: $secondaryPhone).keyboardType(.phonePad)
            TextField("E-posta", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            TextField("Konum", text: $location)
        }
    }

    private var notesSection: some View {
        Section("Notlar") {
            TextField("Notlar", text: $notes, axis: .vertical).lineLimit(3...6)
            Toggle("Favori", isOn: $favorite)
        }
    }

    private var groupsSection: some View {
        Section("Gruplar") {
            ForEach(groups) { group in
                Toggle(group.name, isOn: groupSelectionBinding(for: group.id))
            }
        }
    }

    @ToolbarContentBuilder
    private var contactToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Vazgeç") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Kaydet", action: save).disabled(!canSave)
        }
    }

    private func groupSelectionBinding(for groupID: UUID) -> Binding<Bool> {
        Binding(
            get: { selectedGroupIDs.contains(groupID) },
            set: { isSelected in
                if isSelected {
                    selectedGroupIDs.insert(groupID)
                } else {
                    selectedGroupIDs.remove(groupID)
                }
            }
        )
    }

    private func loadSelectedPhoto(_ oldItem: PhotosPickerItem?, _ newItem: PhotosPickerItem?) {
        Task {
            photoData = try? await newItem?.loadTransferable(type: Data.self)
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
