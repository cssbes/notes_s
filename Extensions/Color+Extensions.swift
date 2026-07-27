import SwiftUI

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        guard hex.count == 6, let intValue = UInt64(hex, radix: 16) else { return nil }
        self.init(
            .sRGB,
            red: Double((intValue >> 16) & 0xFF) / 255.0,
            green: Double((intValue >> 8) & 0xFF) / 255.0,
            blue: Double(intValue & 0xFF) / 255.0,
            opacity: 1.0
        )
    }

    static let themePrimary = Color(hex: "#C77D4A") ?? .orange
    static let themeSecondary = Color(hex: "#8B6B5C") ?? .brown
    static let themeBackground = Color(hex: "#FAF8F5") ?? Color(.systemGroupedBackground)
    static let themeSurface = Color(.systemBackground)
    static let themeText = Color(hex: "#2C2416") ?? .primary
    static let themeSubtle = Color(hex: "#9E917F") ?? .secondary
    static let themeAccent = Color(hex: "#C77D4A") ?? .orange
    static let themeCard = Color(hex: "#F5F2ED") ?? Color(.systemGray6)
    static let themeBorder = Color(hex: "#E8E3DC") ?? Color(.systemGray5)
}
