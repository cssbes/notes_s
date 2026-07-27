import Foundation
import SwiftData

enum AppLanguage: String, CaseIterable, Identifiable {
    case auto
    case arabic
    case english

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .auto: return "Automatic"
        case .arabic: return "العربية"
        case .english: return "English"
        }
    }

    var localeIdentifier: String? {
        switch self {
        case .auto: return nil
        case .arabic: return "ar"
        case .english: return "en"
        }
    }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var systemImage: String {
        switch self {
        case .system: return "gear"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

enum AppFontFamily: String, CaseIterable, Identifiable {
    case system
    case serif
    case monospace
    case rounded

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .serif: return "Serif"
        case .monospace: return "Monospace"
        case .rounded: return "Rounded"
        }
    }
}

@Model
final class AppSettings {
    @Attribute(.unique) var id: UUID
    var isDarkMode: Bool
    var fontSize: Double
    var fontFamilyRaw: String
    var languageRaw: String
    var themeRaw: String
    var accentColorHex: String
    var lastBackupDate: Date?
    var hasCompletedOnboarding: Bool

    init() {
        self.id = UUID()
        self.isDarkMode = false
        self.fontSize = 16.0
        self.fontFamilyRaw = AppFontFamily.system.rawValue
        self.languageRaw = AppLanguage.auto.rawValue
        self.themeRaw = AppTheme.system.rawValue
        self.accentColorHex = "#007AFF"
        self.hasCompletedOnboarding = false
    }

    var fontFamily: AppFontFamily {
        get { AppFontFamily(rawValue: fontFamilyRaw) ?? .system }
        set { fontFamilyRaw = newValue.rawValue }
    }

    var language: AppLanguage {
        get { AppLanguage(rawValue: languageRaw) ?? .auto }
        set { languageRaw = newValue.rawValue }
    }

    var theme: AppTheme {
        get { AppTheme(rawValue: themeRaw) ?? .system }
        set { themeRaw = newValue.rawValue }
    }
}
