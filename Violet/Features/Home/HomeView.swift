import SwiftUI

struct HomeView: View {
    enum Filter: String, CaseIterable, Identifiable {
        case all = "Alle"
        case playlists = "Playlists"
        case artists = "Künstler"

        var id: Self { self }
    }

    @State private var filter: Filter = .all

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 8) {
                        ForEach(Filter.allCases) { option in
                            FilterChip(title: option.rawValue, isSelected: filter == option) {
                                filter = option
                            }
                        }
                    }

                    EmptyStateView(
                        systemImage: "music.note.house",
                        title: "Noch nichts zu hören",
                        message: "Importiere Songs über „Erstellen“. Danach erscheinen hier deine Playlists und zuletzt gehörte Songs."
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Start")
        }
    }
}
