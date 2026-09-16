import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    var body: some View {
        Form {
            Section("Varsayılan Arama Uygulaması") {
                Label("Durum, iOS Ayarları tarafından yönetilir", systemImage: "checkmark.shield")
                Text("Bu uygulamayı iPhone Ayarları'ndan varsayılan arama uygulamanız olarak ayarlayın.").foregroundStyle(.secondary)
                Button("Uygulama Ayarlarını Aç") { if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) } }
            }
            Section("Gizlilik") { Label("Kişiler ve aramalar yalnızca bu aygıtta saklanır.", systemImage: "lock.fill") }
        }.navigationTitle("Ayarlar")
    }
}
