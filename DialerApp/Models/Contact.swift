import Foundation
import SwiftData

@Model
final class Contact {
    @Attribute(.unique) var id: UUID
    var projectID: UUID
    var firstName: String
    var lastName: String
    var company: String
    var jobTitle: String
    var primaryPhone: String
    var secondaryPhone: String?
    var email: String?
    var location: String?
    var notes: String?
    var photoData: Data?
    var colorSeed: Int
    var isFavorite: Bool
    var isActive: Bool
    var createdAt: Date
    var deletedAt: Date?
    @Relationship(inverse: \ContactGroup.contacts) var groups: [ContactGroup]

    init(
        id: UUID = UUID(),
        projectID: UUID = AppScope.projectID,
        firstName: String,
        lastName: String = "",
        company: String = "",
        jobTitle: String = "",
        primaryPhone: String,
        secondaryPhone: String? = nil,
        email: String? = nil,
        location: String? = nil,
        notes: String? = nil,
        photoData: Data? = nil,
        colorSeed: Int = Int.random(in: 0..<6),
        isFavorite: Bool = false,
        isActive: Bool = true,
        createdAt: Date = .now
    ) {
        self.id = id
        self.projectID = projectID
        self.firstName = firstName
        self.lastName = lastName
        self.company = company
        self.jobTitle = jobTitle
        self.primaryPhone = primaryPhone
        self.secondaryPhone = secondaryPhone
        self.email = email
        self.location = location
        self.notes = notes
        self.photoData = photoData
        self.colorSeed = colorSeed
        self.isFavorite = isFavorite
        self.isActive = isActive
        self.createdAt = createdAt
        self.deletedAt = nil
        self.groups = []
    }

    var displayName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    var initials: String {
        [firstName, lastName].compactMap(\.first).map(String.init).joined().uppercased()
    }


    var searchableText: String {
        ([firstName, lastName, displayName, company, jobTitle, primaryPhone, secondaryPhone ?? "",
          location ?? ""] + groups.map(\.name)).joined(separator: " ")
    }
}

enum AppScope {
    /// Local data is partitioned so every SwiftData query is scoped explicitly.
    static let projectID = UUID(uuidString: "52B3BD45-3D23-4E19-B24F-C5E179A22D81")!
}
