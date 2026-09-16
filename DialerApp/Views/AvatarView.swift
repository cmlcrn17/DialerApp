import SwiftUI
import UIKit

struct AvatarView: View {
    let initials: String
    let seed: Int
    var photoData: Data? = nil
    var size: CGFloat = 48
    private let colors: [Color] = [.indigo, .cyan, .mint, .orange, .pink, .purple]

    nonisolated init(initials: String, seed: Int, photoData: Data? = nil, size: CGFloat = 48) {
        self.initials = initials; self.seed = seed; self.photoData = photoData; self.size = size
    }
    init(contact: Contact, size: CGFloat = 48) {
        initials = contact.initials; seed = contact.colorSeed; photoData = contact.photoData; self.size = size
    }

    var body: some View {
        Group {
            if let photoData, let image = UIImage(data: photoData) {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Text(initials.isEmpty ? "?" : initials)
                    .font(.system(size: size * 0.34, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(colors[abs(seed) % colors.count].gradient)
            }
        }.frame(width: size, height: size).clipShape(Circle()).accessibilityHidden(true)
    }
}
