import Foundation
import SwiftData

@Model
final class ContactGroup {
    @Attribute(.unique) var id: UUID
    var projectID: UUID
    var name: String
    var icon: String
    var isActive: Bool
    var deletedAt: Date?
    var contacts: [Contact]

    init(name: String, icon: String = "person.2.fill") {
        id = UUID()
        projectID = AppScope.projectID
        self.name = name
        self.icon = icon
        isActive = true
        deletedAt = nil
        contacts = []
    }
}
