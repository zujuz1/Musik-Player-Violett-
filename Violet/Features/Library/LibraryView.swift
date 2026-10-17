import SwiftUI

struct LibraryView: View {
    enum Filter: String, CaseIterable, Identifiable {
        case playlists = "Playlists"
        case artists = "Künstler"
        case albums = "Alben"

        var id: Self { self }
    }

    /// `nil` = kein Filter aktiv. Erneutes Tippen hebt den Filter wieder auf.
    @State private var filter: Filter?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 8) {
                        ForEach(Filter.allCases) { option in
                            FilterChip(title: option.rawValue, isSelected: filter == option) {
                                filter = (filter == option) ? nil : option
                            }
                        }
                    }

                    EmptyStateView(
                        systemImage: "books.vertical",
                        title: "Deine Bibliothek ist leer",
                        message: "Hier findest du bald alle Songs, Playlists, Künstler und Alben."
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Bibliothek")
        }
    }
}
