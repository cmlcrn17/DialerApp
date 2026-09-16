import SwiftData
import SwiftUI

struct GroupsView: View {
    @Environment(\.modelContext) private var context
    @Query private var groups: [ContactGroup]
    @State private var newName = ""
    @State private var showingCreate = false
    @State private var groupToRename: ContactGroup?
    @State private var renameText = ""
    init() {
        let projectID = AppScope.projectID
        _groups = Query(filter: #Predicate<ContactGroup> { $0.projectID == projectID && $0.isActive && $0.deletedAt == nil }, sort: [SortDescriptor(\ContactGroup.name)])
    }
    var body: some View {
        NavigationStack {
            List {
                ForEach(groups) { group in
                    NavigationLink { GroupMembersView(group: group) } label: {
                        HStack(spacing: 14) { Image(systemName: group.icon).foregroundStyle(.blue).frame(width: 48, height: 48).background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 14)); VStack(alignment: .leading) { Text(group.name).font(.headline); Text("\(group.contacts.filter { $0.isActive && $0.deletedAt == nil }.count) kişi").font(.caption).foregroundStyle(.secondary) } }
                    }.swipeActions {
                        Button(role: .destructive) { group.deletedAt = .now; group.isActive = false; try? context.save() } label: { Label("Sil", systemImage: "trash") }
                        Button { groupToRename = group; renameText = group.name } label: { Label("Yeniden Adlandır", systemImage: "pencil") }.tint(.blue)
                    }
                }
            }.listStyle(.plain).navigationTitle("Gruplar")
                .toolbar { Button { showingCreate = true } label: { Image(systemName: "plus") } }
                .alert("Yeni Grup", isPresented: $showingCreate) { TextField("Grup adı", text: $newName); Button("Oluştur") { let name = newName.trimmingCharacters(in: .whitespaces); if !name.isEmpty { context.insert(ContactGroup(name: name)); try? context.save() }; newName = "" }; Button("Vazgeç", role: .cancel) {} }
                .alert("Grubu Yeniden Adlandır", isPresented: Binding(get: { groupToRename != nil }, set: { if !$0 { groupToRename = nil } })) {
                    TextField("Grup adı", text: $renameText)
                    Button("Kaydet") { let name = renameText.trimmingCharacters(in: .whitespaces); if !name.isEmpty { groupToRename?.name = name; try? context.save() }; groupToRename = nil }
                    Button("Vazgeç", role: .cancel) { groupToRename = nil }
                }
        }
    }
}

struct GroupMembersView: View {
    @Bindable var group: ContactGroup
    @State private var selecting = false
    var body: some View {
        List { ForEach(group.contacts.filter { $0.isActive && $0.deletedAt == nil }) { ContactCard(contact: $0) }.onDelete { offsets in group.contacts.remove(atOffsets: offsets) } }
            .navigationTitle(group.name).toolbar { Button("Kişi Ekle") { selecting = true } }
            .sheet(isPresented: $selecting) { ContactPickerView(group: group) }
    }
}

struct ContactPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var group: ContactGroup
    @Query private var contacts: [Contact]
    init(group: ContactGroup) { self.group = group; let projectID = AppScope.projectID; _contacts = Query(filter: #Predicate<Contact> { $0.projectID == projectID && $0.isActive && $0.deletedAt == nil }, sort: [SortDescriptor(\Contact.firstName)]) }
    var body: some View { NavigationStack { List(contacts) { contact in Button { if !group.contacts.contains(where: { $0.id == contact.id }) { group.contacts.append(contact); try? context.save() } } label: { HStack { AvatarView(contact: contact); Text(contact.displayName); Spacer(); if group.contacts.contains(where: { $0.id == contact.id }) { Image(systemName: "checkmark.circle.fill") } } }.foregroundStyle(.primary) }.navigationTitle("Kişi Ekle").toolbar { Button("Bitti") { dismiss() } } } }
}
