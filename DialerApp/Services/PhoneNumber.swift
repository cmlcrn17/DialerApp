import Foundation

enum PhoneNumber {
    static func normalized(_ rawValue: String) -> String? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let prefix = trimmed.hasPrefix("+") ? "+" : ""
        let digits = trimmed.filter(\.isNumber)
        guard (3...15).contains(digits.count) else { return nil }
        return prefix + digits
    }
}
