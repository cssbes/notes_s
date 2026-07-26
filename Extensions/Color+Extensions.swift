import SwiftUI

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        guard hex.count == 6, let intValue = UInt64(hex, radix: 16) else {
            return nil
        }

        self.init(
            .sRGB,
            red: Double((intValue >> 16) & 0xFF) / 255.0,
            green: Double((intValue >> 8) & 0xFF) / 255.0,
            blue: Double(intValue & 0xFF) / 255.0,
            opacity: 1.0
        )
    }

    static var accent: Color {
        .blue
    }

    static var cardBackground: Color {
        Color(.systemBackground)
    }

    static var groupedBackground: Color {
        Color(.systemGroupedBackground)
    }

    static var secondaryFill: Color {
        Color(.secondarySystemFill)
    }
}
