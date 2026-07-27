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

    static let nBackground = Color(.systemBackground)
    static let nSurface = Color(.systemGray6)
    static let nText = Color(.label)
    static let nSecondary = Color(.secondaryLabel)
    static let nTertiary = Color(.tertiaryLabel)
    static let nAccent = Color(.systemBlue)
    static let nDivider = Color(.separator).opacity(0.3)
    static let nCard = Color(.systemGray6)
}
