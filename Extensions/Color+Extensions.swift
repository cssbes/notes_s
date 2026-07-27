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

    static var accent: Color { .blue }

    static var cardBackground: Color { Color(.systemBackground) }

    static var groupedBackground: Color { Color(.systemGroupedBackground) }

    static var secondaryFill: Color { Color(.secondarySystemFill) }

    static var editorBackground: Color {
        Color(.systemBackground)
    }

    static var editorText: Color {
        Color(.label)
    }

    static var noteAccent: Color { Color(hex: "#007AFF") ?? .blue }
    static var noteGreen: Color { Color(hex: "#34C759") ?? .green }
    static var noteOrange: Color { Color(hex: "#FF9500") ?? .orange }
    static var noteRed: Color { Color(hex: "#FF3B30") ?? .red }
    static var notePurple: Color { Color(hex: "#AF52DE") ?? .purple }

    static var gradientStart: Color { Color(hex: "#667eea") ?? .blue }
    static var gradientEnd: Color { Color(hex: "#764ba2") ?? .purple }

    static var surfaceLight: Color { Color(.systemGray6) }
    static var surfaceDark: Color { Color(.systemGray5) }

    static var premiumBackground: Color {
        Color(.systemGroupedBackground)
    }
}
