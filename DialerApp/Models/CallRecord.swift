import Foundation
import SwiftData

@Model
final class CallRecord {
    @Attribute(.unique) var id: UUID
    var projectID: UUID
    var contactName: String
    var phoneNumber: String
    var startedAt: Date
    var isActive: Bool
    var deletedAt: Date?

    init(contactName: String, phoneNumber: String, startedAt: Date = .now) {
        self.id = UUID()
        self.projectID = AppScope.projectID
        self.contactName = contactName
        self.phoneNumber = phoneNumber
        self.startedAt = startedAt
        self.isActive = true
    }
}
