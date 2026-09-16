import SwiftData
import SwiftUI

struct AddContactView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""

    private var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty && PhoneNumber.normalized(phoneNumber) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Ad") {
                    TextField("Ad", text: $firstName).textContentType(.givenName)
                    TextField("Soyad", text: $lastName).textContentType(.familyName)
                }
                Section("Telefon") {
                    TextField("+90 555 000 00 00", text: $phoneNumber)
                        .keyboardType(.phonePad).textContentType(.telephoneNumber)
                }
                Section { Text("Kişi bilgileri sistem rehberine aktarılmaz.").foregroundStyle(.secondary) }
            }
            .navigationTitle("Yeni Kişi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Vazgeç") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Kaydet", action: save).disabled(!canSave) }
            }
        }
    }

    private func save() {
        guard let normalized = PhoneNumber.normalized(phoneNumber) else { return }
        context.insert(Contact(
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            phoneNumber: normalized
        ))
        try? context.save()
        dismiss()
    }
}
