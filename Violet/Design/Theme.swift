import SwiftUI

enum Theme {
    static let background = Color(hex: 0x121212)
    static let surface = Color(hex: 0x1E1E1E)
    static let surfaceElevated = Color(hex: 0x2A2A2A)

    static let textPrimary = Color(hex: 0xFFFFFF)
    static let textSecondary = Color(hex: 0xA7A7A7)

    static let accent = Color(hex: 0xA970FF)

    static let cornerRadius: CGFloat = 8
    static let cardCornerRadius: CGFloat = 12
}

extension Color {
    /// Farbe aus einem Hex-Wert wie 0xA970FF.
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
