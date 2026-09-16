import Foundation
import SwiftData

@Model
final class CallRecord {
    @Attribute(.unique) var id: UUID
    var projectID: UUID
    var contactName: String
    var contactID: UUID?
    var company: String
    var phoneNumber: String
    var startedAt: Date
    var isActive: Bool
    var deletedAt: Date?
    var callType: String
    var duration: TimeInterval?

    init(contactName: String, phoneNumber: String, contactID: UUID? = nil, company: String = "", startedAt: Date = .now) {
        self.id = UUID()
        self.projectID = AppScope.projectID
        self.contactName = contactName
        self.contactID = contactID
        self.company = company
        self.phoneNumber = phoneNumber
        self.startedAt = startedAt
        self.isActive = true
        self.deletedAt = nil
        self.callType = "outgoing"
        self.duration = nil
    }
}
