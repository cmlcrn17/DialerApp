import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            ContactsView()
                .tabItem { Label("Kişiler", systemImage: "person.2.fill") }
            KeypadView()
                .tabItem { Label("Tuşlar", systemImage: "circle.grid.3x3.fill") }
            RecentsView()
                .tabItem { Label("Son Aramalar", systemImage: "clock.fill") }
        }
        .tint(.indigo)
    }
}
