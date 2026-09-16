import Foundation

enum PhoneNumber {
    static func normalized(_ rawValue: String) -> String? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let prefix = trimmed.hasPrefix("+") ? "+" : ""
        let digits = trimmed.filter(\.isNumber)
        guard (3...15).contains(digits.count) else { return nil }
        if prefix == "+" { return "+" + digits }
        if digits.count == 10, digits.hasPrefix("5") { return "+90" + digits }
        if digits.count == 11, digits.hasPrefix("0") { return "+90" + String(digits.dropFirst()) }
        return digits
    }

    static func formatted(_ rawValue: String) -> String {
        guard let number = normalized(rawValue) else { return rawValue }
        guard number.hasPrefix("+90"), number.count == 13 else { return number }
        let digits = String(number.dropFirst(3))
        return "+90 \(digits.prefix(3)) \(digits.dropFirst(3).prefix(3)) \(digits.dropFirst(6).prefix(2)) \(digits.suffix(2))"
    }
}
