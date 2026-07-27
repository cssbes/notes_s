import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    private let noteService: NoteService
    private let backupService: BackupService

    var isDarkMode = false
    var fontSize: Double = 16.0
    var fontFamily: AppFontFamily = .system
    var language: AppLanguage = .auto
    var theme: AppTheme = .system
    var accentColorHex: String = "#007AFF"
    var lastBackupDate: Date?
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?
    var showRestorePicker = false

    var formattedLastBackup: String {
        guard let date = lastBackupDate else { return "Never" }
        let f = DateFormatter(); f.dateStyle = .short; f.timeStyle = .short; return f.string(from: date)
    }

    init(noteService: NoteService, backupService: BackupService) {
        self.noteService = noteService
        self.backupService = backupService
        loadSettings()
    }

    func loadSettings() {
        isLoading = true

        do {
            let descriptor = FetchDescriptor<AppSettings>()
            let settings = try noteService.context.fetch(descriptor)

            if let settings = settings.first {
                isDarkMode = settings.isDarkMode
                fontSize = settings.fontSize
                fontFamily = settings.fontFamily
                language = settings.language
                theme = settings.theme
                accentColorHex = settings.accentColorHex
            } else {
                let defaults = AppSettings()
                noteService.context.insert(defaults)
                try noteService.context.save()
            }

            lastBackupDate = backupService.getBackupCreationDate()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func saveThemePreference() {
        save { $0.isDarkMode = isDarkMode }
    }

    func saveFontSize() {
        save { $0.fontSize = fontSize }
    }

    func saveFontFamily() {
        save { $0.fontFamily = fontFamily }
    }

    func saveLanguage() {
        save { $0.language = language }
    }

    func saveTheme() {
        save { $0.theme = theme }
    }

    func saveAccentColor() {
        save { $0.accentColorHex = accentColorHex }
    }

    private func save(_ update: (inout AppSettings) -> Void) {
        do {
            let descriptor = FetchDescriptor<AppSettings>()
            let settings = try noteService.context.fetch(descriptor)
            let appSettings = settings.first ?? AppSettings()
            update(&appSettings)
            try noteService.context.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createBackup() {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let _ = try backupService.createBackup()
            lastBackupDate = Date()
            successMessage = "Backup created successfully."
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func restoreBackup(from url: URL) {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            try backupService.restoreBackup(from: url)
            successMessage = "Backup restored successfully."
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
