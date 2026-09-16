import SwiftData
import SwiftUI
import UIKit

struct ContactDetailView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var calls: CallCoordinator
    @Bindable var contact: Contact
    @State private var editing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                AvatarView(contact: contact, size: 124)
                VStack(spacing: 4) { Text(contact.displayName).font(.largeTitle.bold()); Text(contact.jobTitle).font(.title3).foregroundStyle(.secondary); Text(contact.company).foregroundStyle(.secondary) }
                HStack(spacing: 14) {
                    ActionButton(title: "Ara", icon: "phone.fill", color: .blue, prominent: true) { calls.call(contact, context: context) }
                    ActionButton(title: "Mesaj", icon: "message.fill", color: .green) { openMessage() }
                    ActionButton(title: "Favori", icon: contact.isFavorite ? "star.fill" : "star", color: .orange) { contact.isFavorite.toggle(); try? context.save() }
                }
                InfoCard(icon: "phone.fill", title: "Telefon", value: PhoneNumber.formatted(contact.primaryPhone))
                if let email = contact.email, !email.isEmpty { InfoCard(icon: "envelope.fill", title: "E-posta", value: email) }
                InfoCard(icon: "building.2.fill", title: "Şirket", value: contact.company)
                if let location = contact.location, !location.isEmpty { InfoCard(icon: "location.fill", title: "Konum", value: location) }
                if !contact.groups.isEmpty { InfoCard(icon: "person.2.fill", title: "Gruplar", value: contact.groups.map(\.name).joined(separator: ", ")) }
            }.padding()
        }.navigationTitle("Kişi").navigationBarTitleDisplayMode(.inline)
            .toolbar { Button("Düzenle") { editing = true } }
            .sheet(isPresented: $editing) { AddContactView(contact: contact) }
    }
    private func openMessage() {
        guard let number = PhoneNumber.normalized(contact.primaryPhone), let url = URL(string: "sms:\(number)") else { return }
        UIApplication.shared.open(url)
    }
}

private struct ActionButton: View {
    let title: String; let icon: String; let color: Color; var prominent = false; let action: () -> Void
    var body: some View { Button(action: action) { VStack(spacing: 7) { Image(systemName: icon).font(.title2); Text(title).font(.caption.bold()) }.foregroundStyle(prominent ? .white : color).frame(maxWidth: .infinity).frame(height: 76).background(prominent ? AnyShapeStyle(color.gradient) : AnyShapeStyle(color.opacity(0.12)), in: RoundedRectangle(cornerRadius: 18)) }.accessibilityLabel(title) }
}
private struct InfoCard: View {
    let icon: String; let title: String; let value: String
    var body: some View { HStack(spacing: 14) { Image(systemName: icon).foregroundStyle(.blue).frame(width: 36, height: 36).background(.blue.opacity(0.1), in: Circle()); VStack(alignment: .leading, spacing: 2) { Text(title).font(.caption).foregroundStyle(.secondary); Text(value).font(.body) }; Spacer() }.padding().frame(maxWidth: .infinity).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18)) }
}
