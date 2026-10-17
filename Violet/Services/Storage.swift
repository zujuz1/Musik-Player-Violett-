import Foundation

/// Ablageorte im App-Container.
enum Storage {
    /// `Documents/Music` – hier liegen alle Audiodateien.
    static var musicDirectory: URL {
        URL.documentsDirectory.appending(path: "Music", directoryHint: .isDirectory)
    }

    /// Legt den Musik-Ordner an, damit er in der Dateien-App sichtbar ist.
    static func prepare() {
        try? FileManager.default.createDirectory(
            at: musicDirectory,
            withIntermediateDirectories: true
        )
    }
}
