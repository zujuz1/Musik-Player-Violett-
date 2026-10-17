import SwiftUI

struct CreateView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    CreateRow(
                        systemImage: "music.note.list",
                        title: "Neue Playlist",
                        subtitle: "Kommt in Phase 3"
                    )
                    CreateRow(
                        systemImage: "square.and.arrow.down",
                        title: "Songs importieren",
                        subtitle: "Kommt in Phase 2"
                    )
                    CreateRow(
                        systemImage: "sparkles",
                        title: "Neu, noch nicht bearbeitet",
                        subtitle: "Kommt in Phase 2"
                    )
                }
                .padding(16)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Erstellen")
        }
    }
}

private struct CreateRow: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .fill(Theme.surfaceElevated)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .fill(Theme.surface)
        )
    }
}
