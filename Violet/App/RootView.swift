import SwiftUI

enum AppTab: Hashable {
    case home
    case search
    case library
    case create
}

struct RootView: View {
    @State private var selection: AppTab = .home

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem { Label("Start", systemImage: "house.fill") }
                .tag(AppTab.home)

            SearchView()
                .tabItem { Label("Suche", systemImage: "magnifyingglass") }
                .tag(AppTab.search)

            LibraryView()
                .tabItem { Label("Bibliothek", systemImage: "books.vertical.fill") }
                .tag(AppTab.library)

            CreateView()
                .tabItem { Label("Erstellen", systemImage: "plus.circle.fill") }
                .tag(AppTab.create)
        }
    }
}
