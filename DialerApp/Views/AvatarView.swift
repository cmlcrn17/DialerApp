import SwiftUI

struct AvatarView: View {
    let initials: String
    let seed: Int
    var size: CGFloat = 48

    private let colors: [Color] = [.indigo, .cyan, .mint, .orange, .pink, .purple]

    var body: some View {
        Text(initials.isEmpty ? "?" : initials)
            .font(.system(size: size * 0.34, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(colors[abs(seed) % colors.count].gradient, in: Circle())
            .accessibilityHidden(true)
    }
}
