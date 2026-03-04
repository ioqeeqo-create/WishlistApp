import SwiftUI

struct ContentView: View {
    @StateObject private var vm = WishlistViewModel(
        context: PersistenceController.shared.container.viewContext)

    var body: some View {
        TabView {
            HomeView()
                .environmentObject(vm)
                .tabItem { Label("Вишлисты", systemImage: "gift.fill") }
            ProfileView()
                .environmentObject(vm)
                .tabItem { Label("Профиль", systemImage: "person.fill") }
        }
        .tint(Color(hex: "#A78BFA"))
    }
}
