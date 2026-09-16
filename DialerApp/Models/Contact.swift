import Foundation
import SwiftData

@Model
final class Contact {
    @Attribute(.unique) var id: UUID
    var projectID: UUID
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var colorSeed: Int
    var isFavorite: Bool
    var isActive: Bool
    var createdAt: Date
    var deletedAt: Date?

    init(
        id: UUID = UUID(),
        projectID: UUID = AppScope.projectID,
        firstName: String,
        lastName: String = "",
        phoneNumber: String,
        colorSeed: Int = Int.random(in: 0..<6),
        isFavorite: Bool = false,
        isActive: Bool = true,
        createdAt: Date = .now
    ) {
        self.id = id
        self.projectID = projectID
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.colorSeed = colorSeed
        self.isFavorite = isFavorite
        self.isActive = isActive
        self.createdAt = createdAt
    }

    var displayName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    var initials: String {
        [firstName, lastName].compactMap(\.first).map(String.init).joined().uppercased()
    }
}

enum AppScope {
    /// Local data is partitioned so every SwiftData query is scoped explicitly.
    static let projectID = UUID(uuidString: "52B3BD45-3D23-4E19-B24F-C5E179A22D81")!
}
