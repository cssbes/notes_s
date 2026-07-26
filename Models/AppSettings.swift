import Foundation
import SwiftData

@Model
final class AppSettings {
    @Attribute(.unique) var id: UUID
    var isDarkMode: Bool
    var fontSize: Double
    var lastBackupDate: Date?
    var hasCompletedOnboarding: Bool

    init() {
        self.id = UUID()
        self.isDarkMode = false
        self.fontSize = 16.0
        self.hasCompletedOnboarding = false
    }
}
