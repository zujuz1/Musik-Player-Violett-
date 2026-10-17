import SwiftUI

struct SearchView: View {
    @State private var query = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                EmptyStateView(
                    systemImage: "magnifyingglass",
                    title: query.isEmpty ? "Was möchtest du hören?" : "Keine Ergebnisse",
                    message: "Suche nach Songs, Künstlern, Alben und Playlists."
                )
                .padding(.top, 24)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Suche")
            .searchable(
                text: $query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Songs, Künstler, Alben"
            )
        }
    }
}
